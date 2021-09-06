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

      def translate(key, *params)
        format messages(key), *params
      rescue
        error = {
          Util::Options::LANG_JA => "メッセージ取得に失敗しました。(#{key})"
        }[@options[:lang]] || "Failed to retrieve message. (#{key})"
        raise error
      end

      alias t translate

      def messages(key)
        (file, *path) = key.split '.'

        string = (@messages[file] ||= YAML.load_file "#{I18N_DIR}/#{@options[:lang]}/#{file}.yaml")
        string = string[path.shift] until path.empty?
        string
      end
    end
  end
end
