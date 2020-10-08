require 'yaml'

module Util
  class ReservedWords
    private_class_method :new

    # Relative to project root
    RESERVED_WORD_LIST_PATH = './config/reserved_words.yaml'.freeze

    class << self
      def variable?(name)
        reserved_word_list['variables'].include? name
      end

      def function?(name)
        reserved_word_list['functions'].include? name
      end

      private

      def reserved_word_list
        @reserved_word_list ||= YAML.load_file(RESERVED_WORD_LIST_PATH)
      end
    end
  end
end
