module Tokenizer
  class Lexer
    module Validators
      ##########################################################################
      # Methods for determining the validity of chunks.
      # These methods should not mutate or return any value, simply throw an
      # error if the current state is considered invalid.
      ##########################################################################

      def validate_sequence_finish
        return if @tokens.empty? && !@context.inside_if_block? && !@context.inside_assignment?
        raise Errors::UnexpectedEof
      end

      def validate_token_sequence(chunk)
        raise Errors::UnexpectedEol if eol? chunk
        raise Errors::UnexpectedInput, chunk
      end

      def validate_variable_name(name)
        raise Errors::AssignmentToValue, name if Oracles::Value.value?(name) && name !~ /^(それ|あれ)$/
        raise Errors::VariableNameReserved, name if Util::ReservedWords.variable? name
        raise Errors::VariableNameAlreadyDelcaredAsFunction, name if @current_scope.function? name
      end

      def validate_function_def_parameter(token, parameters)
        raise Errors::InvalidFunctionDefParameter, token.content if token.type != Token::PARAMETER
        raise Errors::VariableNameReserved, token.content if Util::ReservedWords.variable? token.content
        raise Errors::FunctionDefPrimitiveParameters if token.sub_type != Token::VARIABLE
        raise Errors::FunctionDefDuplicateParameters if parameters.include? token.content
      end

      def validate_function_name(name, signature)
        raise Errors::FunctionDefNonVerbName, name unless Conjugator.verb? name
        # TODO: (Bug) Should not bubble up function? here
        raise Errors::FunctionDefAlreadyDeclared, name if @current_scope.function? name, signature
        raise Errors::FunctionDefReserved, name if Util::ReservedWords.function? name
      end

      def validate_return_parameter(chunk, parameter_token, property_token = nil)
        raise Errors::UnexpectedReturn, chunk unless parameter_token

        validate_parameter parameter_token, property_token

        validate_return_parameter_particle chunk, parameter_token
      end

      def validate_return_parameter_particle(chunk, parameter_token)
        expected_particle = chunk == 'なる' ? 'と' : 'を'
        return if parameter_token.particle == expected_particle
        raise Errors::InvalidReturnParameterParticle.new(parameter_token.particle, expected_particle)
      end

      def validate_loop_iterator_parameter(parameter_token, property_token = nil)
        validate_loop_iterator_property_and_attribute property_token, parameter_token if property_token

        raise Errors::InvalidLoopParameterParticle, parameter_token.particle unless parameter_token.particle == 'に'

        return if variable?(parameter_token.content) || Oracles::Value.string?(parameter_token.content)
        raise Errors::InvalidLoopParameter, parameter_token.content
      end

      def validate_loop_iterator_property_and_attribute(property_token, parameter_token)
        raise Errors::InvalidLoopParameter, property_token.content unless property_token.type == Token::PROPERTY

        # TODO: (v1.1.0) Remove
        raise Errors::ExperimentalFeature, parameter_token.content unless parameter_token.sub_type == Token::ATTR_LEN

        valid_property_owners = [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE]
        unless valid_property_owners.include? property_token.sub_type
          raise Errors::InvalidPropertyOwner, property_token.content
        end

        validate_property_and_attribute property_token, parameter_token
      end

      def validate_loop_parameters(parameter_token, property_token = nil)
        if property_token
          validate_property_and_attribute property_token, parameter_token
        else
          valid_sub_types = [Token::VARIABLE, Token::VAL_NUM]
          return if valid_sub_types.include? parameter_token.sub_type
          raise Errors::InvalidLoopParameter, parameter_token.content
        end
      end

      # The parameter is a proper rvalue and is a valid attribute if applicable.
      def validate_parameter(parameter_token, property_token = nil)
        if property_token
          validate_property_and_attribute property_token, parameter_token
        elsif !rvalue? parameter_token.content
          raise VariableDoesNotExist, parameter_token.content
        end
      end

      def validate_scope(expected_type, options = { ignore: [], error_class: nil })
        current_scope = @current_scope
        until current_scope.nil? || current_scope.type == expected_type
          unless options[:ignore].include? current_scope.type
            # rubocop:disable Style/RaiseArgs
            raise options[:error_class].new(current_scope.type) unless options[:error_class].nil?
            # rubocop:enable Style/RaiseArgs
            raise Errors::UnexpectedScope.new(expected_type, current_scope.type)
          end
          current_scope = current_scope.parent
        end
        raise "Expected scope #{expected_type} not found" if current_scope.nil? # NOTE: Untested
      end

      def validate_property_and_attribute(property_token, attribute_token)
        raise Errors::UnexpectedInput, property_token.content if property_token.type != Token::PROPERTY

        # TODO: (v1.1.0) Remove
        raise Errors::ExperimentalFeature, attribute_token.content unless attribute_token.sub_type == Token::ATTR_LEN

        attribute = attribute_token.content
        raise Errors::AccessOfSelfAsAttribute, attribute if attribute == property_token.content

        if property_token.sub_type == Token::VAL_STR
          validate_string_attribute attribute_token
        else
          # NOTE: Untested (redundant check)
          raise Errors::VariableDoesNotExist, property_token.content unless variable? property_token.content

          # NOTE: Untested (redundant check)
          attribute_type attribute
        end
      end

      def validate_string_attribute(attribute_token)
        valid_string_attributes = [Token::ATTR_LEN, Token::KEY_INDEX, Token::KEY_VAR, Token::VAR_SORE, Token::VAR_ARE]
        return if valid_string_attributes.include? attribute_token.sub_type
        raise Errors::InvalidStringAttribute, attribute_token.content
      end

      # TODO: (v1.1.0) Fix doc for token naming for subject.
      # Validates that each logical operation (accounting for v1.1.0 lists of
      # logical comparisons) include only one comp_1 (comp_2 has a stricter
      # sequence and doesn't need to be checked).
      def validate_logical_operation
        return if @tokens.empty?

        last_comma_index = @tokens.reverse.index { |t| t.type == Token::COMMA } || 0
        comparators = @tokens.slice(last_comma_index...-1).select do |token|
          token.type == Token::RVALUE || token.type == Token::PROPERTY
        end
        raise Errors::InvalidPropertyComparison.new(*comparators[0..1].map(&:content)) if comparators.size > 2
      end
    end
  end
end
