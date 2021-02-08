require './src/tokenizer/conjugator'

include Tokenizer

RSpec.describe Conjugator, 'verbs' do
  describe '#verb?' do
    it 'considers verbs ending in う to be verbs' do
      expect(Conjugator.verb?('買う')).to be_truthy
    end

    it 'considers verbs ending in く to be verbs' do
      expect(Conjugator.verb?('開く')).to be_truthy
    end

    it 'considers verbs ending in ぐ to be verbs' do
      expect(Conjugator.verb?('濯ぐ')).to be_truthy
    end

    it 'considers verbs ending in す to be verbs' do
      expect(Conjugator.verb?('流す')).to be_truthy
    end

    it 'does not consider verbs ending in ず to be verbs' do
      expect(Conjugator.verb?('みず')).to be_falsy
    end

    it 'considers verbs ending in つ to be verbs' do
      expect(Conjugator.verb?('持つ')).to be_truthy
    end

    it 'does not consider verbs ending in づ to be verbs' do
      expect(Conjugator.verb?('くらふとふーづ')).to be_falsy
    end

    it 'considers verbs ending in ぬ to be verbs' do
      expect(Conjugator.verb?('死ぬ')).to be_truthy
    end

    it 'does not consider verbs ending in ふ to be verbs' do
      expect(Conjugator.verb?('ぱふぱふ')).to be_falsy
    end

    it 'does not consider verbs ending in ぷ to be verbs' do
      expect(Conjugator.verb?('こっぷ')).to be_falsy
    end

    it 'considers verbs ending in ぶ to be verbs' do
      expect(Conjugator.verb?('呼ぶ')).to be_truthy
    end

    it 'considers verbs ending in む to be verbs' do
      expect(Conjugator.verb?('読み込む')).to be_truthy
    end

    it 'does not consider verbs ending in ゆ to be verbs' do
      expect(Conjugator.verb?('見ゆ')).to be_falsy
    end

    it 'considers verbs ending in る to be verbs' do
      expect(Conjugator.verb?('切る')).to be_truthy
    end
  end

  describe '#conjugate' do
    it 'conjugates 五段 verbs ending in う' do
      expect(Conjugator.conjugate('買う')).to contain_exactly('買って', '買った')
    end

    it 'conjugates 五段 verbs ending in く' do
      expect(Conjugator.conjugate('開く')).to contain_exactly('開いて', '開いた')
    end

    it 'conjugates 五段 verb / verb phrases ending in く' do
      expect(Conjugator.conjugate('行く')).to contain_exactly('行って', '行った')
      expect(Conjugator.conjugate('持っていく')).to contain_exactly('持っていって', '持っていった')
    end

    it 'conjugates 五段 verbs ending in ぐ' do
      expect(Conjugator.conjugate('濯ぐ')).to contain_exactly('濯いで', '濯いだ')
    end

    it 'conjugates 五段 verbs ending in す' do
      expect(Conjugator.conjugate('流す')).to contain_exactly('流して', '流した')
    end

    it 'conjugates 五段 verbs ending in つ' do
      expect(Conjugator.conjugate('持つ')).to contain_exactly('持って', '持った')
    end

    it 'conjugates 五段 verbs ending in ぬ' do
      expect(Conjugator.conjugate('死ぬ')).to contain_exactly('死んで', '死んだ')
    end

    it 'conjugates 五段 verbs ending in ぶ' do
      expect(Conjugator.conjugate('呼ぶ')).to contain_exactly('呼んで', '呼んだ')
    end

    it 'conjugates 五段 verbs ending in む' do
      expect(Conjugator.conjugate('読み込む')).to contain_exactly('読み込んで', '読み込んだ')
    end

    it 'does not conjugate verbs ending in ゆ' do
      expect(Conjugator.conjugate('見ゆ')).to be_empty
    end

    it 'conjugates both 五段 and 一段 verbs ending in る' do
      expect(Conjugator.conjugate('かえる')).to contain_exactly('かえて', 'かえって', 'かえた', 'かえった')
    end

    it 'conjugates 不規則動詞 verb する' do
      expect(Conjugator.conjugate('動作する')).to contain_exactly('動作して', '動作した')
    end

    it 'conjugates 不規則動詞 verb / verb phrases with くる' do
      expect(Conjugator.conjugate('来る')).to contain_exactly('来て', '来た')
      expect(Conjugator.conjugate('戻ってくる')).to contain_exactly('戻ってきて', '戻ってきた')
    end

    it 'conjugates 不規則動詞 verb 問う' do
      expect(Conjugator.conjugate('問う')).to contain_exactly('問うて', '問うた')
    end
  end
end
