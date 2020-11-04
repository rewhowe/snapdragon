# 金魚草(スナップドラゴン) - snapdragon

[English](../README.md)

## 紹介

プログラミング言語を作ってみましょう・・・！！

金魚草とは単純で自然な日本語のプログラミング言語・・・の筈です。

昔の[ひまわり](https://ja.wikipedia.org/wiki/ひまわり_%28プログラミング言語%29)とその後継の[なでしこ](https://ja.wikipedia.org/wiki/なでしこ_%28プログラミング言語%29)を元にした金魚草は趣味として作らています。

花の種類のパターンを続けて、「[金魚草](https://ja.wikipedia.org/wiki/キンギョソウ)」（英語：[snapdragon](https://en.wikipedia.org/wiki/Antirrhinum)）も花の名前です。

## 準備

1. [rbenv](https://github.com/rbenv/rbenv#installation) をインストール。
```bash
rbenv local
# 2.3.0 です
```

2. [bundler](https://bundler.io) をインストール：
```bash
gem install bundler
```

3. ジェムをインストール：
```bash
bundle install
```

4. プログラム動作確認
```bash
./snapdragon -v
```

5. （ルートディレクトリから）テストを実行：
```bash
rspec
```

## 使用

* コマンドオプション一覧： `./snapdragon --help`

### 書き方

* [資料集・マニュアル](./manual_jp.md)

* 「example」というフォルダーを見て

## バージョン履歴

* 1.1.0 (開発予定)

  * 文字列補間

  * 条件分岐（複数条件）

  * 連想配列

  * その他の数学（冪乗、冪根、対数）

  * 例外処理

* 1.0.0 (開発中)

  * 変数 (数字、文字列、ブーリアン型、配列、それ・あれ）

  * 約物（句読文字）

  * 関数

  * コメント

  * 条件分岐（単一条件)

  * ビルトイン

  * 反復

  * プロパティーズ（配列、文字列の長さ）

  * インタープリター
