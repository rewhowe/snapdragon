module Tokenizer
  class Lexer
    module Validators
      ##########################################################################
      # Methods for determining the validity of chunks.
      # These methods should not mutate or return any value, simply throw an
      # error if the current state is considered invalid.
      ##########################################################################

      def validate_variable_name(name)
        raise Errors::AssignmentToValue, name if Oracles::Value.value?(name) && name !~ /\A(それ|あれ)\z/
        raise Errors::VariableNameReserved, name if Util::ReservedWords.variable? name
        raise Errors::VariableNameIllegalCharacters, name if Util::ReservedWords.illegal? name
        raise Errors::VariableNameAlreadyDelcaredAsFunction, name if @current_scope.function? name
      end

      def validate_function_def_parameter(token, parameters)
        raise Errors::VariableNameReserved, token.content if Util::ReservedWords.variable? token.content
        raise Errors::FunctionDefPrimitiveParameters if token.sub_type != Token::VARIABLE
        raise Errors::FunctionDefDuplicateParameters if parameters.include? token.content
      end

      def validate_function_name(name, signature)
        raise Errors::FunctionDefNonVerbName, name unless Conjugator.verb? name
        raise Errors::FunctionDefAlreadyDeclared, name if @current_scope.function? name, signature, bubble_up?: false
        raise Errors::FunctionDefReserved, name if Util::ReservedWords.function? name
        raise Errors::FunctionNameAlreadyDelcaredAsVariable, name if @current_scope.variable?(name) && signature.empty?
      end

      def validate_property_assignment(property_token, property_owner_token)
        validate_property_and_owner property_token, property_owner_token
        valid_property_owners = [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE]
        unless valid_property_owners.include? property_owner_token.sub_type
          raise Errors::AssignmentToValue, property_owner_token.content
        end
        return unless Oracles::Property.read_only? property_token.sub_type
        raise Errors::AssignmentToReadOnlyProperty, property_token.content
      end

      def validate_return_parameter(chunk, parameter_token, property_owner_token = nil)
        raise Errors::UnexpectedReturn, chunk unless parameter_token

        validate_parameter parameter_token, property_owner_token

        validate_return_parameter_particle chunk, parameter_token
      end

      def validate_return_parameter_particle(chunk, parameter_token)
        expected_particle = chunk == 'なる' ? 'と' : 'を'
        return if parameter_token.particle == expected_particle
        raise Errors::InvalidReturnParameterParticle.new(parameter_token.particle, expected_particle)
      end

      def validate_loop_iterator_parameter(parameter_token, property_owner_token = nil)
        raise Errors::InvalidLoopParameterParticle, parameter_token.particle unless parameter_token.particle == 'に'

        parameter = parameter_token.content
        if property_owner_token
          validate_loop_iterator_property_and_owner parameter_token, property_owner_token
          raise Errors::InvalidLoopParameter, parameter unless Oracles::Property.iterable? parameter_token.sub_type
        else
          return if variable?(parameter) || Oracles::Value.string?(parameter)
          raise Errors::InvalidLoopParameter, parameter
        end
      end

      def validate_loop_iterator_property_and_owner(parameter_token, property_owner_token)
        unless property_owner_token.type == Token::POSSESSIVE
          raise Errors::InvalidLoopParameter, property_owner_token.content
        end

        valid_property_owners = [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE]
        unless valid_property_owners.include? property_owner_token.sub_type
          raise Errors::InvalidPropertyOwner, property_owner_token.content
        end

        validate_property_and_owner parameter_token, property_owner_token
      end

      def validate_loop_parameters(parameter_token, property_owner_token = nil)
        if property_owner_token
          validate_property_and_owner parameter_token, property_owner_token
        else
          valid_sub_types = [Token::VARIABLE, Token::VAL_NUM, Token::VAR_SORE, Token::VAR_ARE]
          if valid_sub_types.include? parameter_token.sub_type
            return if parameter_token.sub_type != Token::VARIABLE || variable?(parameter_token.content)
            raise Errors::VariableDoesNotExist, parameter_token.content
          end
          raise Errors::InvalidLoopParameter, parameter_token.content
        end
      end

      # The parameter is a proper rvalue and is a valid property if applicable.
      def validate_parameter(parameter_token, property_owner_token = nil)
        if property_owner_token
          validate_property_and_owner parameter_token, property_owner_token
        elsif !rvalue? parameter_token.content
          raise Errors::VariableDoesNotExist, parameter_token.content
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

      def validate_property_and_owner(property_token, property_owner_token)
        raise Errors::UnexpectedInput, property_owner_token.content if property_owner_token.type != Token::POSSESSIVE

        property = property_token.content
        raise Errors::AccessOfSelfAsProperty, property if property == property_owner_token.content

        return if property_owner_token.sub_type == Token::VAL_STR

        raise Errors::VariableDoesNotExist, property_owner_token.content unless variable? property_owner_token.content
        # skip validating property as indices have already been sanitized at this point
      end

      def validate_interpolation_tokens(interpolation_tokens)
        valid_substitution_sub_types = [Token::VARIABLE, Token::VAR_SORE, Token::VAR_ARE]
        substitution_token = interpolation_tokens[0]
        unless valid_substitution_sub_types.include? substitution_token.sub_type
          raise Errors::InvalidSubstitution, substitution_token.content
        end

        property_token = interpolation_tokens[1]
        return if property_token.nil?

        property = property_token.content
        raise Errors::AccessOfSelfAsProperty, property if property == substitution_token.content
      end
    end
  end
end
