[English](./manual.md)

# 変数について

変数の定義は次のようなフォーマット：`【変数名】は 【バリュー】`

例）

```
ホゲは 1
```

`ホゲ`という`1`のバリューを持つ変数が作られます。

## バリューとデータ型

変数は初期値と共に定義しなくてはなりません。単純なバリューを直接に引数として関数に渡すことが出来ます。

### 数値

数値は次のようなフォーマット：`/-?(\d+\.\d+|\d+)/`（即ちマイナスや浮動小数点数可能）

例）

```
ホゲは -3.14
```

### 文字列

文字列は`「`で始まって、`」`で終わります。

例）

```
ホゲは 「もじれつ」
```

`」`の前に`\`を付けると文字通りの`」`を書くことが出来ます。

例）

```
ホゲは 「文字列の中の「もじれつ\」」
```

#### 文字列補間

(v1.1.0 実装予定)

### 配列

配列は一つ以上のバリュー持つカンマ（全角・半角可能）区切りリストです。

例）

```
ホゲは 1、2、3
フガは 1,2,3
ピヨは 「あ」、「い」、「う」、1、2、3
```

`配列`というキーワードで空の配列の定義が出来ます。

例）

```
ホゲは 配列
```

#### 連想配列（ハッシュ）

(v1.1.0 実装予定)

### ブーリアン型

| ブーリアン値 | 使用可能キーワード         |
| ------------ | -------------------------- |
| True         | `真`, `肯定`, `はい`, `正` |
| False        | `偽`, `否定`, `いいえ`     |

### それ / あれ

[なでしこ](https://ja.wikipedia.org/wiki/なでしこ_%28プログラミング言語%29)と同じく、最後の実行した命令の結果を持つ`それ`というグローバルキーワードが使えます。

しかも、`あれ`というグローバルキーワードもあります。好きなように使ってください！

----

# 関数について

## 関数の定義

関数の定義は次のようなフォーマット：`【引数（任意）】 【関数名】とは`

関数名は動詞（又は動詞句）で、同じスコープに重複の定義（ビルトイン関数も含まれ）は出来ません（※）。関数の中身は一個のスペース（全角・半角可能）のインデントが必要です。

引数との助詞の指定も必要です。助詞は引数名に含まれません。使用可能助詞は`から`, `で`, `と`, `に`, `へ`, `まで`, `を`。

例）

```
友達と 食べ物を 道具で 食べるとは
　・・・
```

This function, "食べる" takes three parameters: "友達", "食べ物", and "道具".

※ The particles used to define the function become part of its signature. A function with the same name can be declared as long as its signature is different (overloading).

## 関数の呼び出し

A function is simply called by its name (with any associated parameters, if applicable). If a function signature contains parameters, a function call must supply them (no default parameters).

```
友達と 話すとは
　・・・

「金魚草さん」と 話す
```

A function definition's parameter order will be preserved according to their particles even if a function call's parameters are in a different order.

例）

```
友達と 食べ物を 道具で 食べるとは
　・・・

「箸」で 「金魚草さん」と 「ふわふわ卵のヒレカツ丼」を 食べる
```

As mentioned in the section on "Variables", a function's return value will be available via the global variable それ.

Functions which throw an error will naturally return null (see the section on "Punctuation" for allowing error-throwing).

## 活用（動詞の語形変化）

When a function is defined, its た-form (aka "perfective", "past tense") and て-form (aka "participle", "command") conjugations also become available. Verbs ending with いる and える are difficult to distinguish between 五段動詞 and 一段動詞 so both conjugations are available (just in case!).

例）

```
食べ物を 食べるとは
　・・・

「ふわふわ卵のヒレカツ丼」を 食べた
「もうひとつのヒレカツ丼」を 食べて
```

----

# 制限公文について

## 条件分岐

A conditional branch follows the format: `もし 【条件式】`. The body must be indented one space (full-width or half-width).

The conditional statement is generally comprised of three parts: comparator 1, comparator 2, and comparator 3 (creative, I know).

Comparator 1 follows the format: `[variable or value]が`.

Comparator 2 is a variable or value followed by one of `と`, `より`, `以上`, `以下`, `?`.

Comparator 3 is one of `ならば`, `等しければ`, `大きければ`, `小さければ`.

Comparator 2 and comparator 3, together, form the logical operator, and follow the format: `[variable or value][comparator 2] [comparator 3]`. Comparator 2 using a question mark (full-width `？` or half-width `?`) is equivalent to a normal `===` comparison. The associated comparator 3 is `ならば`.

Below is a chart of various comparisons between two variables, `Ａ` and `Ｂ`:

| 比較文                             | 論理演算子        |
| ---------------------------------- | ----------------- |
| もし　Ａが　Ｂと　　等しければ     | `Ａ === Ｂ`       |
| もし　Ａが　Ｂより　大きければ     | `Ａ > Ｂ`         |
| もし　Ａが　Ｂより　小さければ     | `Ａ < Ｂ`         |
| もし　Ａが　Ｂ以上　ならば         | `Ａ >= Ｂ`        |
| もし　Ａが　Ｂ以下　ならば         | `Ａ <= Ｂ`        |
| もし　Ａが　Ｂと　　等しくなければ | `Ａ !== Ｂ`       |
| もし　Ａが　Ｂ？　　ならば         | `Ａ === Ｂ`       |

Comparator 3 can be written in plain ひらがな as well (without kanji).

例）

```
もし Ａが Ｂと ひとしければ
　・・・
```

Additionally, `大きければ` and `少なければ` have several aliases (for semantic purposes).

| Greater Than (>) | Less Than (<) |
| ---------------- | ------------- |
| 大きければ       | 小さければ    |
| 長ければ         | 短ければ      |
| 高ければ         | 低ければ      |
| 多ければ         | 少なければ    |

Of course, these can also be written in plain ひらがな.

### 関数呼び出しの条件

In addition to the three-part conditional statement, function calls suffixed by a question mark (full-width `？` or half-width `?`) and `ならば` can also be used as conditions.

例）

```
もし 「ふわふわ卵のヒレカツ丼」を 食べた？ ならば
　・・・
```

### 複数条件分岐

(v1.1.0 実装予定)

## 繰り返し（反復）

TODO

----

# 例外処理

TODO

----

# 雑題

## 無演算命令

Like Python's `pass`, Snapdragon provies `・・・` as a no-op. You can use it to stub functions for later implementation, or to signify an intentionally-empty block.

## コメント

インラインコメントは`(`又は`（`で始まります。*（独り言のよう*

`※`に囲まれる文はブロックコメントとなります。

例）

```
予定は 「買い物」（本当はゲーセン

※仕様未定※
プロジェクトするとは
　・・・

※
　作者：金魚草さん
　日時：2018-01-01 09:00:00
　バージョン： 1.0.0
※
```

## 約物（句読文字）

### ビックリマーク（感嘆符）

Functions, by default, will return null. Suffixing a function call with an exclamation mark (full-width `！` or half-width `!`) will allow errors to be thrown (see the section on "Try-Catch" for handling).

例）

```
食べ物を 食べるとは
　・・・

「プラスチック」を 食べる　（エラー無し
「プラスチック」を 食べる！（エラー有り
```

### ハテナマーク（疑問符）

A variable or function call suffixed with a question mark (full-width `？` or half-width `?`) will have its value or return value cast to a boolean (see the section on "Conditional Branching" for use within conditional statements).

例）

```
食べ物を 食べるとは
　・・・

「ふわふわ卵のヒレカツ丼」を 食べる？
ホゲは それ
```

This is equivalent to

```
「ふわふわ卵のヒレカツ丼」を 食べる
ホゲは それ？
```

----

# ビルトイン関数（組み込み関数）

| 関数シグネチャ                       | 仕様                                    |
| ------------------------------------ | --------------------------------------- |
| `言葉と 言う`                        | `printf` / `print` / `console.log` / 等 |
| `言葉を 言う`                        | 〃（文法的な差のみ)                     |
| `メッセージを ログする`              | ログに出力 / `console.log` / 等         |
| `メッセージを 表示する`              | 標準出力 / `print` / `alert` / 等       |
| `エラーを 投げる`                    | 標準エラー出力 / `raise` / `alert` / 等 |
| `追加対象を 対象列に 追加する`       | 配列・文字列対応                        |
| `連結対象を 対象列に 連結する`       | 配列・文字列対応                        |
| `対象列から 抜き対象を 抜く`         | 最初の`抜き対象`を`対象列`から抜く      |
| `対象列から 抜き対象を 全部抜く`     | 全ての`抜き対象`を`対象列`から抜く      |
| `被加数に 加数を 足す`               | 加法                                    |
| `加数を 足す`                        | 〃（被加数は`それ`）                    |
| `被減数から 減数を 引く`             | 減法                                    |
| `減数を 引く`                        | 〃（被減数は`それ`）                    |
| `被乗数に 乗数を 掛ける`             | 乗法                                    |
| `乗数を 掛ける`                      | 〃（被乗数は`それ`）                    |
| `被除数を 除数で 割る`               | 除法                                    |
| `除数で 割る`                        | 〃（被除数は`それ`）                    |
| `被除数を 除数で 割った余りを求める` | 剰余算                                  |
| `除数で 割った余りを求める`          | 〃（被除数は`それ`）                    |

As you may expect, all of the above built-ins can be written in plain ひらがな.
