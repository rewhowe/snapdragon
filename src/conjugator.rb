# extremely rough verb conjugator
class Conjugator
  VERB_ENDINGS = %w[う く ぐ す つ ぬ ぶ む る].freeze
  KANA = '[\u3041-\u3096\u30A0-\u30FF]'.freeze

  class << self
    def verb?(name)
      VERB_ENDINGS.include?(name[-1])
    end

    def conjugate(name)
      # probably a する verb
      return suru_conjugation(name) if name =~ /する$/

      # probably a くる verb
      return kuru_conjugation(name) if name =~ /(て|で)くる$/

      # ends in る could be either 五段動詞 or 一段動詞
      return ru_conjugtation(name) if name =~ /る$/

      # everything else should be standard
      godan_conjugation(name)
    end

    def suru_conjugation(name)
      base = name.slice 0...-2
      [base + 'して', base + 'した']
    end

    def kuru_conjugation(name)
      base = name.slice(0...-2)
      [base + 'きて', base + 'きた']
    end

    def ru_conjugtation(name)
      base = name.slice(0...-1)
      [base + 'て', base + 'た', base + 'って', base + 'った']
    end

    # rubocop:disable Metrics/MethodLength
    def godan_conjugation(name)
      base = name.slice(0...-1)

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
    # rubocop:enable Metrics/MethodLength
  end
end
