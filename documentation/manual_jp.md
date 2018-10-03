[English](./manual.md)

# 前置き

下手な日本語ですみませんです。

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

上記の`食べる`という関数には、`友達`、`食べ物`、と`道具`という引数があります。

※関数の引数が使う助詞もシグナチャーに含まれます。助詞が違えば、同じ関数名を重複定義することが出来ます。

## 関数の呼び出し

関数を単純に関数名で呼び出します。デフォルト値の引数が提供されない為、関数のシグナチャーには引数があればその引数を渡さないとなりません。

```
友達と 話すとは
　・・・

「金魚草さん」と 話す
```

関数の呼び出しの引数の助詞が関数の定義と異なる順番の際には、引数が定義の順番通りに使われます。

例）

```
友達と 食べ物を 道具で 食べるとは
　・・・

「箸」で 「金魚草さん」と 「ふわふわ卵のヒレカツ丼」を 食べる
```

「変数について」に前述したとおり、呼び出した関数の戻り値が`それ`というグローバル変数に代入されます。

エラーが投げらた際には、ヌルが返されます（エラー投げの詳しくは「約物（句読文字）」より見てください）。

## 活用（動詞の語形変化）

関数を定義するタイミングで、該当するた形とて形の活用も定義されます。五段動詞と一段動詞の区別が曖昧な為、「いる」と「える」で終わる動詞の際には、両方の活用形が使えます。

例）

```
食べ物を 食べるとは
　・・・

「ふわふわ卵のヒレカツ丼」を 食べた
「もうひとつのヒレカツ丼」を 食べて
「まだまだヒレカツ丼」を 食べって （変ながら可能
```

----

# 制限公文について

## 条件分岐

条件分岐は次のようなフォーマット：`もし 【条件式】`。分岐の中身は一個のスペース（全角・半角可能）のインデントが必要です。

条件式は普段、3つの部分に分けられます：比1、比2、比3（*比*較演算子）

比1は次のようなフォーマット：`【バリュー】が`。このバリューは一方の比較対象。

比2は他方の比較対象と接尾の`と`、`より`、`以上`、`以下`、とハテナマーク（全角・半角可能）のどれか。

比3は`ならば`、`等しければ`、`大きければ`、`小さければ`のどれか。

比較演算子となる比2と比3の組み合わせは次のフォーマット：`【バリュー】【比2】 【比3】`。比2がハテナマークの際には比較演算子が`===`となります。該当する比3は`ならば`です。

下記は`Ａ`と`Ｂ`という変数のそれぞれの比較文：

| 比較文                             | 論理演算子        |
| ---------------------------------- | ----------------- |
| もし　Ａが　Ｂと　　等しければ     | `Ａ === Ｂ`       |
| もし　Ａが　Ｂより　大きければ     | `Ａ > Ｂ`         |
| もし　Ａが　Ｂより　小さければ     | `Ａ < Ｂ`         |
| もし　Ａが　Ｂ以上　ならば         | `Ａ >= Ｂ`        |
| もし　Ａが　Ｂ以下　ならば         | `Ａ <= Ｂ`        |
| もし　Ａが　Ｂと　　等しくなければ | `Ａ !== Ｂ`       |
| もし　Ａが　Ｂ？　　ならば         | `Ａ === Ｂ`       |

ちなみに、比3は漢字だけではなく、ひらがなでも書けます。

例）

```
もし Ａが Ｂと ひとしければ
　・・・
```

さらに、`大きければ`と`小さければ`は類語と入れ替えることが出来ます。

| より大きい (>) | より小さい (<) |
| -------------- | -------------- |
| 大きければ     | 小さければ     |
| 長ければ       | 短ければ       |
| 高ければ       | 低ければ       |
| 多ければ       | 少なければ     |

勿論、これらもひらがなで書けます。

### 関数呼び出しの条件

3分の条件式と同じように、関数の呼び出しと接尾のハテナマーク（全角・半角可能）、そして比3の`ならば`は分岐条件として使えます。

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

Python の`pass`の同様に金魚草は`・・・`という無演算命令を提供しています。後回しの実装の為や空なブロックの意図を示す為に使われます。

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

関数の呼び出しにエラーが発生したらヌルが返されます。呼び出しの命令の最後にビックリマーク（全角・半角可能）を付けるとエラーが浮かび上がります（詳しくは「例外処理」より見てください）。

例）

```
食べ物を 食べるとは
　・・・

「プラスチック」を 食べる　（エラー無し
「プラスチック」を 食べる！（エラー有り
```

### ハテナマーク（疑問符）

変数や関数の呼び出しの末尾にハテナマークを付けるとバリュー又は戻り値がブーリアン型にキャストされます（条件式での使い方に関しては「条件分岐」より見て下さい）。

例）

```
食べ物を 食べるとは
　・・・

「ふわふわ卵のヒレカツ丼」を 食べた？
ホゲは それ
```

下記も等しい：

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

恐らく思う通り、全てのビルトインはひらがなでも書けます。