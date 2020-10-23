# extremely rough verb conjugator
module Tokenizer
  class Conjugator
    private_class_method :new

    VERB_ENDINGS = %w[う く ぐ す つ ぬ ぶ む る].freeze
    KANA = '[\u3041-\u3096\u30A0-\u30FF]'.freeze

    class << self
      def verb?(name)
        VERB_ENDINGS.include? name[-1]
      end

      def conjugate(name)
        # probably a する verb
        if name =~ /する$/
          base = name.slice 0...-2
          [base + 'して', base + 'した']

        # probably a trailing くる verb
        elsif name =~ /[てでに]?[来く]る$/
          base = name.slice(0...-1).gsub(/く$/, 'き')
          [base + 'て', base + 'た']

        # probably a trailing いく verb
        elsif name =~ /[行い]く$/
          base = name.slice 0...-1
          [base + 'って', base + 'った']

        # ends in る could be either 五段動詞 or 一段動詞
        elsif name =~ /る$/
          base = name.slice 0...-1
          [base + 'て', base + 'た', base + 'って', base + 'った']

        elsif name =~ /問う$/
          [name + 'て', name + 'た']

        # everything else should be standard
        else
          conjugate_godan_verb name
        end
      end

      private

      def conjugate_godan_verb(name)
        base = name.slice 0...-1

        case name[-1]
        when 'う', 'つ'
          [base + 'って', base + 'った']
        when 'く'
          [base + 'いて', base + 'いた']
        when 'ぐ'
          [base + 'いで', base + 'いだ']
        when 'す'
          [base + 'して', base + 'した']
        when 'ぬ', 'ぶ', 'む'
          [base + 'んで', base + 'んだ']
        else
          []
        end
      end
    end
  end
end
