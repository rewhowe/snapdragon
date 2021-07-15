require 'yaml'

require_relative 'options'

module Util
  class I18n
    private_class_method :new

    I18N_DIR = "#{__dir__}/../../config/i18n".freeze

    @options = {}
    @messages = {}

    class << self
      def setup(options)
        @options = options
      end

      def t(key, *params)
        format message(key), *params
      rescue
        raise ({
          Util::Options::LANG_JA => 'メッセージ取得に失敗しました。'
        }[@options[:lang]] || 'Failed to retrieve message.')
      end

      private

      def message(key)
        (file, *path) = key.split '.'

        string = (@messages[file] ||= YAML.load_file "#{I18N_DIR}/#{@options[:lang]}/#{file}.yaml")
        string = string[path.shift] until path.empty?
        string
      end
    end
  end
end
