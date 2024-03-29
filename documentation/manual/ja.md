[English](./en.md)

## 目次

* [変数について](#変数について)
  * [数値](#数値)
  * [文字列](#文字列)
  * [配列](#配列)
  * [ブーリアン型](#ブーリアン型)
  * [ヌル](#ヌル)
  * [それ・あれ](#それあれ)
  * [変数の属性](#変数の属性)
* [制限公文について](#制限公文について)
  * [条件分岐](#条件分岐)
  * [複数条件分岐](#複数条件分岐)
  * [繰り返し（反復）](#繰り返し反復)
  * [例外処理](#例外処理)
* [関数について](#関数について)
  * [関数の定義](#関数の定義)
  * [関数の呼び出し](#関数の呼び出し)
  * [活用（動詞の語形変化）](#活用動詞の語形変化)
* [雑題](#雑題)
  * [インデント](#インデント)
  * [改行](#改行)
  * [無演算命令](#無演算命令)
  * [コメント](#コメント)
  * [約物（句読文字）](#約物句読文字)
  * [スクリプト終了](#スクリプト終了)
  * [デバッグ](#デバッグ)
  * [コマンドライン引数](#コマンドライン引数)
  * [REPL](#REPL)
* [ビルトイン関数（組み込み関数）](#ビルトイン関数組み込み関数)
* [キーワード索引](#キーワード索引)

----

## 変数について

変数の定義は次のようなフォーマット：`【変数名】は 【バリュー】`。

例）

```
ホゲは 1
```

`ホゲ`という`1`のバリューを持つ変数が作られます。

予約語に一致したり、無効文字を含むもの以外、変数名は殆ど無制限です。無効文字：`\`（バックスラッシュ、詳しくは「[改行](#改行)」より参照してください）、`￥ｎ`（二文字、円記号＋全角「ｎ」）、`【`、`】`。予約語の属性に一致する変数名より、属性が優先されます。詳しくは[配列・文字列の属性](#配列文字列の属性)より参照してください。


変数は初期値と共に定義しなくてはなりません。単純なバリューを直接に引数として関数に渡すことが出来ます。

### 数値

数値は次のようなフォーマット：`/-?(\d+\.\d+|\d+)/`（即ちマイナスや浮動小数点数可能）。全角数字も可能です。

例）

```
ホゲは -3.14
```

最大の絶対値は未定義です。

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

複数行の文字列も可能です。先頭のスペース、末尾のスペース、あと改行も含まれて省略されます。`\n`または`￥ｎ`を書き込むと改行を挿入出来ます。更に`\`を前に付けると改行しません。

```
作文は 「こんにちは。
         今日の予定は特になし。
         週末にカツ丼を食べに行く。」

「カツ丼が好き。￥ｎ
　毎日食べても飽きない。」を 言う
```

#### 文字列補間

文字列の中に変数や属性をすみつきカッコ（`【`と`】`）で囲で書き込むと、その値を補間することが出来ます。バックスラッシュ（`\`）を前に入力すると、単純なすみつきカッコとなります。

```
名前は 「世界」
「こんにちは【名前】！」を 言う
```

文字列に補間する値はプリミティブ値（単純な整数や文字列など）であることや、更に補間する文字列を含むことが不可能です。

例）

```
「世界【1】の美女は誰？」と 言う      ※ NG
「壁の【「鏡」】に聞いてみた」と 言う ※ NG

僕は 連想配列
僕の 「名前」は 「リュウ」

「こんにちは【僕の 「名前」】！」と 言う       ※ OK
キー名は 「名前」
「こんにちは【僕の キー名】！」と 言う         ※ OK
「こんにちは【僕の 「【キー名】」】！」と 言う ※ NG
```

ブーリアン型の真が「はい」となり、偽が「いいえ」となります。ヌルは空となります。

文字列は、実際には文字の配列として考えることもありです。文字列の中の文字の扱いについては、[連想配列](#連想配列ハッシュ)より参照してください。

### 配列

配列は一つ以上のバリューを持つカンマ（全角・半角可能）区切りのリストです。

例）

```
ホゲは 1、2、3
フガは 1,2,3
ピヨは 「あ」、「い」、「う」、1、2、3、ホゲ
```

`配列`というキーワードで空の配列の定義が出来ます。`連想配列`も可能です。詳しくは次のセクションより参照してください。

例）

```
ホゲは 配列
```

リストが長すぎる時は、カンマの後に折り返しが出来ます。

```
母音は 「あ」、
　　　 「い」、
　　　 「う」、
　　　 「え」、
　　　 「お」
```

複数行の文字列と同じく、先頭・末尾のスペースが無視されますが、`\`と改行で揃わせることが出来ます。詳しくは「[改行](#改行)」より参照してください。

```
参加者は \
　「ウイ」、
　「チャールス」、
　「ジャック＆
　　アジューラ」
```

#### 連想配列（ハッシュ）

配列（と文字列）は連想配列の使い方も可能です。

取得は次のようなフォーマット：`【変数】の 【取得文】`

上記の「取得文」という配列の要素の取得方法は3つ：

* 指数：`【整数】【助数詞】目`。使用可能の助数詞は：`つ`、`人`、`個`、`件`、`匹`、と`文字`。例：`ホゲの 1つ目`
* キー名：単純な文字列。補間も可能。例：`ホゲの 「キー名」`
* キー変数：単純なな既存の変数。「それ」「あれ」も可能。例：`ホゲの 変数`

指数の場合は1オリジンです。「1つ目」は文字通りに配列の先頭の要素（最低指数、添字の0）です。「0つ目」はありません。しかし、キー名やキーを持つ変数の場合、プログラミングの普段通りに0オリジンです。

存在しないキーまたは指数が要素数より大きい、マイナスの場合は、ヌルとなります。

取得方法によると、キーは数字でも文字でも可能です。実は、内部的にはキーが全て「浮動小数点化文字列」の扱いとなっています。次のような取得は同じ：

```
ホゲの 1つ目

ホゲの 「0」

ホゲの 「0.0」

整数の指数は 0
ホゲの 整数の指数

浮動小数点の指数は 0.0
ホゲの 浮動小数点の指数
```

文字列の場合、正常なキーは数字かつ0から文字数までの範囲に限られています。

```
「ホゲ」の １つ目 ※ OK

「ホゲ」の 「0」  ※ OK

文字の位置は 0
「ホゲ」の 文字の位置 ※ OK

「ホゲ」の 「キー名」 ※ NG
```

普段、全角数字は半角数字と区別していません。それと違って、指数の場合は別々として認識しています。次のような取得は同じではありません：

```
ホゲの 「0」

ホゲの 「０」
```

配列の要素の追加に関しては、キーが数値や文字列とは違うデータ型の場合、そのキーが文字列化されます。特に、`真`が`はい`となり、`偽`が`いいえ`となります。ヌルが空の文字列と同じく扱われます。

殆どの場合、新しく追加した要素は追加順となります。キーが既存の最高指数の次の整数となります。

例）

```
例の配列は 連想配列
例の配列の 1つ目は    「あ」 ※ {0: "あ"}
例の配列の 「ほげ」は 「い」 ※ {0: "あ", "ほげ": "い"}
例の配列の 「4.6」は  「う」 ※ {0: "あ", "ほげ": "い", 4.6: "う"}
例の配列の 「ふが」は 「え」 ※ {0: "あ", "ほげ": "い", 4.6: "う", "ふが": "え"}
例の配列に 「お」を 押し込む ※ {0: "あ", "ほげ": "い", 4.6: "う", "ふが": "え", 5: "お"}
```

要素が自由に、何の指数にも紐付くことがある為、`先頭から押し込む`と`先頭を引き出す`という配列の先頭を変更する処理は数値のキーを全てリセットします。`抜く`等の自由に配列の中身を変更する処理はリセットしません。

例）

```
例の配列Ａは 連想配列
例の配列Ａの 1つ目は   「あ」          ※ {0: "あ"}
例の配列Ａの 「4.6」は 「い」          ※ {0: "あ", 4.6: "う"}
例の配列Ａに 「う」を 先頭から押し込む ※ {0: "う", 1: "あ", 2: "う"}

例の配列Ｂは 連想配列
例の配列Ｂの 1つ目は   「あ」 ※ {0: "あ"}
例の配列Ｂの 「4.9」は 「い」 ※ {0: "あ", 4.9: "う"}
例の配列Ｂから 先頭を引き出す ※ {0: "う"}
```

配列の結合の場合：

* 対象列の最高指数に続いて、要素列の指数がリセットされます
* 要素列にあるキー名が、対象列にも存在する場合、対象列の要素が上書きされます
* 上のシナリオに当てはまらない対象列のキーはそのまま変わりません

```
例の配列Ａは 配列
例の配列Ａの 1つ目は    「あ」
例の配列Ａの 「ほげ」は 「い」
例の配列Ａの 「4.6」は  「う」
例の配列Ａの 「ふが」は 「え」
※ {0: "あ", "ほげ": "い", 4.6: "う", "ふが": "え"}

例の配列Ｂは 配列
例の配列Ｂの 1つ目は    「か」
例の配列Ｂの 「ほげ」は 「き」
例の配列Ｂの 「4.9」は  「く」
例の配列Ｂの 「ぴよ」は 「け」
※ {0: "か", "ほげ": "き", 4.9: "く", "ぴよ": "け"}

例の配列Ａに 例の配列Ｂを 結合する
※ {0: "あ", "ほげ": "き", 4.6: "う", "ふが": "え", 5: "か", 6: "く", "ぴよ": "け"}
```

もしかして若干複雑に見えるかもしれませんが、実際には数値のキーと文字列のキーを交えることが少ないと思われます。

### ブーリアン型

| ブーリアン値 | 使用可能キーワード         |
| ------------ | -------------------------- |
| True         | `真`、`肯定`、`はい`、`正` |
| False        | `偽`、`否定`、`いいえ`     |

### ヌル

使用可能キーワード：`無`、`無い`、`無し`、`ヌル`

### それ・あれ

[なでしこ](https://ja.wikipedia.org/wiki/なでしこ_%28プログラミング言語%29)と同じく、最後の実行した命令の結果を持つ`それ`というグローバルキーワードが使えます。

しかも、`あれ`というグローバルキーワードもあります。好きなように使ってください！

### 変数の属性

様々な属性の取得は、次のようなフォーマット：`【変数】の 【属性】`。現在、数値、文字列、又は配列のデータ型の変数しか属性を持てません。単純な文字列の属性も取得出来ます。属性の属性みたいな連鎖取得は不可能です。

下記は使用可能の属性：

| 属性     | 対象           | 代入可能？ | 詳細 |
| -------- | -------------- | ---------- | ---- |
| 長さ     | 配列 or 文字列 | 不可       | 配列の要素数または文字列の文字数 |
| キー列   | 配列 only      | 不可       | 配列がキーの配列 |
| 先頭     | 配列 or 文字列 | 可         | 配列の先頭の要素、または文字列の最初の文字<br>空の場合は空の配列、または空の文字列 |
| 末尾     | 配列 or 文字列 | 可         | 配列の末尾の要素、または文字列の最後の文字<br>空の場合は空の配列、または空の文字列 |
| 先頭以外 | 配列 or 文字列 | 不可       | 先頭の要素以外の要素を持つ配列、または先頭以外の文字列<br>空の場合は空の配列、または空の文字列 |
| 末尾以外 | 配列 or 文字列 | 不可       | 末尾の要素以外の要素を持つ配列、または末尾以外の文字列<br>空の場合は空の配列、または空の文字列 |
| 〇乗     | 数値           | 不可       | 数値の〇乗（冪乗）<br>〇も数値 |
| 〇乗根   | 数値           | 不可       | 数値の〇乗根（冪根）<br>〇も数値 |

`長さ`のエイリアスは`ながさ`、`大きさ`、`おおきさ`、`数`、`かず`、`人数`、`個数`、`件数`、`匹数`、`文字数`。

`キー列`のエイリアスは`インデックス`。

冪乗と冪根の計算は、グローバルの`それ`を使う`その乗`又は`その乗根`でも取得出来ます。`あの乗`又は`あの乗根`にすると、`あれ`で計算されます。更に、`平方`と`自乗`は`２乗`のエイリアスで、`平方根`と`自乗根`も`２乗根`のエイリアスです。対数の計算については、「[算数](#算数)」より参照してください。

例）

```
チームは 「アジューラ」、「チャールス」、「ウイ」
チームの 「サポート」は 「ニッキー」
チームの 「リーダー」は 「セフ」
チーム名は 「T4O」

チームの 長さを 表示する ※ 5
チームの 人数を 表示する ※ これもOK

チーム名の 文字数を 表示する ※ 3
チーム名の 匹数を 表示する   ※ 変だが、あり

チームの キー列を 表示する ※ {0: 0, 1: 1, 2: 2, 3: "サポート", 4: "リーダー"}

チームの 先頭を 表示する     ※ "アジューラ"
チームの 先頭以外を 表示する ※ {0: "チャールス", 1: "ウイ", "サポート": "ニッキー", "リーダー": "セフ"}
チームの 末尾を 表示する     ※ "セフ"
チームの 末尾以外を 表示する ※ {0: "アジューラ", 1: "チャールス", 2: "ウイ", "サポート": "ニッキー"}

2の 3乗を 表示する         ※ 8
256の その乗根 を 表示する ※ 2
4の 自乗を 表示する        ※ 16
```

----

## 制限公文について

### 条件分岐

条件分岐は次のようなフォーマット：`もし 【条件式】`。分岐の中身は一個のホワイトスペース（全角・半角スペースまたはタブ）のインデントが必要です。詳しくは「[インデント](#インデント)」より参照してください。

条件式は普段、3つの部分に分けられます：主語、比較言1、比較言2。

主語は次のようなフォーマット：`【バリュー】が`。このバリューは一方の比較対象。

比較言1は他方の比較対象と接尾の`と 同じ`、`より`、`以上`、`以下`のどれか。

比較言2は意味論によって`ならば`、`なら`、`大きければ`、`小さければ`のどれか。`ならば`、`なら`、と`であれば`は動作的に同様です。

比較演算子となる比較言1と比較言2の組み合わせは次のフォーマット：`【バリュー】【比較言1】 【比較言2】`。

下記は`Ａ`と`Ｂ`という変数のそれぞれの比較文：

| 比較文                             | 論理演算子        |
| ---------------------------------- | ----------------- |
| もし　Ａが　Ｂと　同じ　ならば     | `Ａ == Ｂ`        |
| もし　Ａが　Ｂより　大きければ     | `Ａ > Ｂ`         |
| もし　Ａが　Ｂより　小さければ     | `Ａ < Ｂ`         |
| もし　Ａが　Ｂ以上　ならば         | `Ａ >= Ｂ`        |
| もし　Ａが　Ｂ以下　ならば         | `Ａ <= Ｂ`        |
| もし　Ａが　Ｂ　　　ならば         | `Ａ == Ｂ`        |

`ならば`または`なら`を含む条件式なら、`でなければ`または`じゃなければ`に変えると結果が反転されます。`でなければ`と`じゃなければ`は同様です。

| 比較文                             | 論理演算子        |
| ---------------------------------- | ----------------- |
| もし　Ａが　Ｂと　同じ　でなければ | `Ａ != Ｂ`        |
| もし　Ａが　Ｂ以上　でなければ     | `Ａ < Ｂ`         |
| もし　Ａが　Ｂ以下　でなければ     | `Ａ > Ｂ`         |
| もし　Ａが　Ｂ　でなければ         | `Ａ != Ｂ`        |

`Ａ`と`Ｂ`のデータ型が違えば、論理演算子が`!=`の場合以外、比較文の結果が常に偽となります。

ちなみに、比較言2は漢字だけではなく、ひらがなでも書けます。

例）

```
もし Ａが Ｂと おなじ ならば
　・・・

もし Ａが Ｂより おおきければ
　・・・
```

さらに、`大きければ`と`小さければ`は類語と入れ替えることが出来ます。

| より大きい (>) | より小さい (<) |
| -------------- | -------------- |
| 大きければ     | 小さければ     |
| 長ければ       | 短ければ       |
| 高ければ       | 低ければ       |
| 多ければ       | 少なければ     |

勿論、これらもひらがなで書けます。注意：`大きくなければ`や`小さくなければ`が提供されないが、そういう比較文を`以下 ならば`と`以上 ならば`のように書けます。

#### ブーリアンコンテキストの条件

更に、一つの値にハテナマーク（全角・半角可能）を付けると、ブーリアン型にキャストされた値に対する条件分岐が可能です。該当する比較言2は`ならば`または`でなければ`です。

| 比較文                 | 論理演算子 |
| ---------------------- | ---------- |
| もし　Ａ？　ならば     | `Ａ`       |
| もし　Ａ？　でなければ | `!Ａ`      |

詳しくは「[ハテナマーク（疑問符）](#ハテナマーク疑問符)」より参照してください。

上記と同様ですが、「存在の条件」を意味する形もあります：`もし Aが あれば`。否定するには`なければ`が使えます。

#### 空の条件

空かどうかの判断として、長さを`0`に比較出来ますが、そのコンテナーを`空`に比較することも可能です。ひらがなの`から`も使用可能です。

例）

```
もし 何かの配列の 長さが 0 ならば

※ 下記と同様

もし 何かの配列が 空 ならば
```

もし主語が配列または文字列でなければ、条件式の結果が常に偽となります。

#### コンテナーの中に存在の条件

値がコンテナーに含まれるかどうかを条件に出来ます。フォーマットは`もし 【バリュー】が 【コンテナー】の 中に あれば`。

例）

```
もし 「リュウ」が 「ハオ　リュウ」の 中に あれば
　・・・

もし 私の 大好物が メニューの 中に あれば
　・・・
```

`なければ`に変えると結果が反転されます。

コンテナーが文字列で、バリューが文字列でない場合、結果が常に偽となります。

#### データ型の条件

基本的に、`配列`というキーワードが空の配列に変換されます。しかし、`==`または`!=`の比較条件の2つ目の引数として使う時に、1つ目の引数のデータ型が比較されます。

例）

```
Ａは 1、2、3
Ｂは 「こんにちは」

もし Ａが 配列 ならば # 真
　・・・

もし Ｂが 配列 ならば # 偽
　・・・

もし 配列が Ａ ならば # 偽 - データ型チェックではない
　・・・

もし Ａが 配列より 大きければ # 真 - 「配列」が空の配列となった
　・・・
```

殆どの組み込み関数は文字列と配列を同じく扱うんですが、場合によって同じではありません。こうして、文字列か配列かの判定が出来ます。

#### 関数呼び出しの条件

3分の条件式と同じように、関数の呼び出しと比較言2の`ならば`は分岐条件として使えます。[約物（句読文字）](#約物句読文字)も使用可能ですが、どの場合にも戻り値がブーリアンキャストされます。

例）

```
もし 「ふわふわ卵のヒレカツ丼」を 食べた？ ならば
　・・・
```

`でなければ`にすると、条件が反転される。

#### 「else if」と「else」

「もし」の条件分岐の後に、その文と同じインデントで並んだ「else if」または「else」も使えます。

「else if」は次のようなフォーマット：`もしくは 【条件式】`か`または 【条件式】`。条件式は上記の「もし」文と同じです。複数の「else if」文も可能です。

「else」は独立なキーワードですが、良い響きの為にエイリアスは色々あります：`それ以外ならば`、`それ以外なら`、`それ以外は`、`それ以外だと`、`でなければ`、`じゃなければ`、`違うならば`、`違うなら`、`違えば`。最後の3つだけはひらがな可能です。

例）

```
もし Ａが Ｂと 同じ ならば
　・・・
もしくは Ａが Ｂより 大きければ
　・・・
または Ａが Ｂより 小さければ
　・・・
それ以外は
　・・・
```

条件式を否定するには`でなければ`を使うのです。

### 複数条件分岐

複数の条件を試す分岐も可能です。最終の条件の書き方は今まで通りですが、先行する条件の比較言2は「連用形」となり（または略され）、そして後にカンマと連用論理演算子（`論理積`または`論理和`）が付きます。連用論理演算子については次のセクションより参照してください。

| 通常比較文 / 条件                | 連用形                               |
| -------------------------------- | ------------------------------------ |
| もし　Ａが　Ｂと　同じ　ならば   | もし　Ａが　Ｂと　同じ　であり、 ... |
| もし　Ａが　Ｂより　大きければ   | もし　Ａが　Ｂより　大きく、 ...     |
| もし　Ａが　Ｂより　小さければ   | もし　Ａが　Ｂより　小さく、 ...     |
| もし　Ａが　Ｂ以上　ならば       | もし　Ａが　Ｂ以上　であり、 ...     |
| もし　Ａが　Ｂ以下　ならば       | もし　Ａが　Ｂ以下　であり、 ...     |
| もし　Ａが　Ｂ　　　ならば       | もし　Ａが　Ｂ　　　であり、 ...     |
| もし　Ａが　空　　　ならば       | もし　Ａが　空　　　であり、 ...     |
| もし　Ａが　Ｂの　中に　あれば   | もし　Ａが　Ｂの　中に　あり、 ...   |
| もし　Ａが　Ｂの　中に　なければ | もし　Ａが　Ｂの　中に　なく、 ...   |

こうして、複数条件分岐では`ならば`の代わりに連用形の`であり`という繋辞となります。否定するには`でなく`を使います。エイリアスとして`で`、`じゃなく`も使用可能です。

例）

```
もし 時間が 「12：00」 で、人数が 1以上 ならば
　パーティーを 始める
```

ブーリアンコンテキストの条件と関数呼び出しの条件の場合、繋辞を略します。

| 通常比較文 / 条件            | 連用形                     |
| ---------------------------- | -------------------------- |
| もし　Ａ？　　　　　ならば   | もし　Ａ？、...            |
| もし　関数呼び出す？　ならば | もし　関数呼び出す？、 ... |

こちらもまた、`でなく`で否定出来ます。

`あれば`または`なければ`で終わる「存在の条件」の場合、`あり`と`なく`となります。

| 通常比較条件           | 連用形                |
| ---------------------- | --------------------- |
| もし　Ａ？　ならば     | もし　Ａが　あり、... |
| もし　Ａ？　でなければ | もし　Ａが　なく、... |

しかしながら、`関数呼び出す？ でなく`という書き方が不自然な為、`なく`というエイリアスも提供しています。そして関数名の活用と任意のハテナマークと相まって、`関数呼び出して なく`という書き方も可能です。

最後に、関数を呼び出すと、戻り値が`それ`に代入される為、複数の関数条件を連続で呼び出すと、`それ`が順に上書きされます。

例）

```
それは 1
もし 1を 足して、且つ 2を 足す ならば
　それを 表示する ※ 4 が表示
```

#### 論理積・論理和

金魚草はたった2つの連用論理演算子を提供しています：`論理積`と`論理和`。

複数条件分岐では、次のようにカンマの後に付きます：`もし 【連用形条件式】、【論理積・論理和】【通常条件式】`。勿論、複数の連用形条件式と連用論理演算子を並べます。

`論理積`のキーワードは`且つ`または`かつ`。`論理和`のキーワードは`又は`または`または`です。少し早口言葉になりそうですね。

殆どのプログラミング言語と同様に、`論理積`の優先度が`論理和`より高いです。次の例に注意してください。

前提：`A | B & C`という条件式に`A = 1`、`B = 0`、`C = 0`とすると：

```
A | B & C
1 | 0 & 0 ※ 代入
1 | 0     ※ 論理積が先
1
```

しかし、もしこの条件式が「お客さんが商品を購入できますか？」という場面を表現しているとし、`A`、`B`、`C`を`予約あり`、`在庫あり`、`残高が足りる`としてみると：

```
※ お客さんが商品を購入できますか？
予約あり | 在庫あり & 残高が足りる
1 | 0 & 0 ※ 代入
1 | 0     ※ 論理積が先
1         ※ はい？
```

こういう場合なら、前の結果が正しくないですね。お客さんの残高が足りないのに、購入出来るという結果になります。期待する結果を生み出すには、`(A | B)`のようにカッコを付ける必要があります。

```
※ お客さんが商品を購入できますか？
(予約あり | 在庫あり) & 残高が足りる
(1 | 0) & 0 ※ 代入
1 & 0       ※ 論理和が先
0           ※ いいえ
```

しかし、金魚草にはこのようなカッコの使い方が不可能です。一方で、とある条件式を書くことが不可能なんですが、同時に、条件式を短くて明確に書くことが必須となります。

下記は期待する結果を表現出来る2つの仕方：

修正１： 条件式を入れ子にする

```
もし 予約あり？、又は 在庫あり？ ならば
　もし ユーザの 残高が 0以上 ならば
　　・・・
```

修正２: 論理和の条件をヘルパー関数にする

```
商品があるとは
　もし 予約あり？、又は 在庫あり？ ならば
　　はいと なる

もし 商品がある？、且つ ユーザの 残高が 0以上 ならば
```

### 繰り返し（反復）

反復のキーワードは`繰り返す`。どの漢字とひらがなの組み合わせでも可能です。

反復は二種類です。（任意の）引数のと、コンテナーのようなオブジェクトに対するのです。

`終わり`というキーワードで反復からすぐに離脱出来ます。`次`というキーワードで当回の繰り返しを終えて、次の繰り返しに飛べます。どちらもひらがなで書けます。

反復の中身は一個のホワイトスペース（全角・半角スペースまたはタブ）のインデントが必要です。詳しくは「[インデント](#インデント)」より参照してください。

#### 引数の有無での繰り返し

単純な反復は必ず、2つの引数（始点と終点）、または引数なしの2つのパターンとなる次のフォーマット：`【任意引数】 繰り返す`。

引数なしの場合、`終わり`などで手動で離脱しないと無限ループになります。

2つの引数の場合、両方は変数または数値のどれかを使えます。変数に対しては数値的であるべきというのですが、妥当性の確認がありません。浮動小数点は整数にキャストされます。更に、その引数は始点と終点と指定する「から」と「まで」という助詞を順番自由に使います。終点が含まれます。始点と終点を入れ替えることで逆順の反復が可能です。

例）

```
1から 100まで 繰り返す
　・・・

繰り返す
　「無限ループ？」を 言う
　終わり
```

##### 固定回数繰り返しの速記

短くて便利で、指定した回数だけを繰り返すことも可能です。フォーマットはこちら：`【数値】回 繰り返す`。実際は`1から 【数値】まで 繰り返す`の省略です。

#### オブジェクトに対する繰り返し

コンテナーのようなオブジェクトの中身に対して繰り返すのは次のようなフォーマット：`【オブジェクト】に 対して 繰り返す`。そのオブジェクトは配列系の変数または文字列であるべきなのですが、前者の場合は妥当性の確認がありません。`対して`はひらがなでも書けます。

例）

```
買い物リストに 対して 繰り返す
　アイテムは それ
　もし アイテムを 既に買った？ ならば
　　次
　違えば
　　アイテムを 買う
```

#### 条件による繰り返し

指定した条件を満たす限りの反復も可能です。条件式は殆ど条件分岐と同様です。

複数条件の場合、先行する条件を「連用形」で書きますが、最終の条件の比較言2は「連体形」となり（または略され）、そして後に`限り`（ひらがなの`かぎり`も可能）と`繰り返す`が付きます。全体的なフォーマットは次のよう：`【連用形条件式】、【論理積・論理和】【連体形条件式】限り 繰り返す`。条件分岐と同様に、幾つかの連用形条件式を並べます。

| 通常比較文 / 条件分岐              | 連体形                                     |
| ---------------------------------- | ------------------------------------------ |
| もし　Ａが　Ｂと　同じ　ならば     | Ａが　Ｂと　同じ　である　[限り　繰り返す] |
| もし　Ａが　Ｂより　　　大きければ | Ａが　Ｂより　　　大きい　[限り　繰り返す] |
| もし　Ａが　Ｂより　　　小さければ | Ａが　Ｂより　　　小さい　[限り　繰り返す] |
| もし　Ａが　Ｂ以上　　　ならば     | Ａが　Ｂ以上　　　である　[限り　繰り返す] |
| もし　Ａが　Ｂ以下　　　ならば     | Ａが　Ｂ以下　　　である　[限り　繰り返す] |
| もし　Ａが　Ｂ　　　　　ならば     | Ａが　Ｂ　　　　　である　[限り　繰り返す] |
| もし　Ａが　空　　　　　ならば     | Ａが　空　　　　　である　[限り　繰り返す] |
| もし　Ａが　Ｂの　中に　あれば     | Ａが　Ｂの　中に　　ある　[限り　繰り返す] |
| もし　Ａが　Ｂの　中に　なければ   | Ａが　Ｂの　中に　　ない　[限り　繰り返す] |

条件分岐に比べると、連体形の条件式の`もし`がなく、最後の`ならば`の代わりに連体形の言葉と`限り 繰り返す`が付きます。`である`を否定する`でない`または`じゃない`も使用可能です。

ブーリアンコンテキストの連体形条件式の場合、条件が真、または条件が偽のどれかを満たせば繰り返すのかを指定するキーワードが必要です。連用形条件式は変わりません。`あれば`または`なければ`で終わる「存在の条件」の場合、`ある`と`ない`となります。

| 通常比較文 / 条件分岐  | 連体形                       |
| ---------------------- | ---------------------------- |
| もし　Ａ？　ならば     | Ａ？　真の　[限り　繰り返す] |
| もし　Ａ？　ならば     | Ａが　ある　[限り　繰り返す] |
| もし　Ａ？　でなければ | Ａ？　偽の　[限り　繰り返す] |
| もし　Ａ？　でなければ | Ａが　ない　[限り　繰り返す] |

連体形の関数呼び出しは連用形とほぼ同様です。条件が真の場合、繋辞を略しますが、偽の場合は`でない`または自然な`ない`を書きます。

| 通常比較文 / 条件分岐            | 連体形                                 |
| -------------------------------- | -------------------------------------- |
| もし　関数呼び出す？　ならば     | 関数呼び出す　　　　　[限り　繰り返す] |
| もし　関数呼び出す？　でなければ | 関数呼び出して　ない　[限り　繰り返す] |

例）

```
回数は 0
回数が 10より 小さい 限り 繰り返す ※ 10回反復
　回数に 1を 足す
　回数は それ
```

今までの反復は、始点と終点を変数で指定するとランタイムの時まで限度が決まりませんが、その限度の計算は一回しか行いません。始点と終点の変数の値が変わったとしても、反復の回数が変わりません。しかし、条件による繰り返しの場合、繰り返す度に条件式が計算されます。というわけで、`それ`を受ける関数呼び出しを試す反復だと、`それ`の値が予測不能になることがあります。

例）

```
それは 0

1を 足す 限り 繰り返す ※ 無限ループ
　それを 表示する      ※ 繰り返す度に上がる「それ」を出力

1を 足す 限り 繰り返す ※ 一回ループ（！）
　「【それ】」と 言う  ※ 「それ」が文字列となり、次のループの条件がエラーを投げる
```

### 例外処理

`試す`または`ためす`というキーワードは、例外が発生する可能性のあるブロックを示す。例外が発生した場合、即座に実行が停止し、ブロックの後から安全に継続が出来ます。

条件分岐や反復のブロックと同様に、`試す`のブロックの中身は一個のホワイトスペース（全角・半角スペースまたはタブ）のインデントが必要です。

例）

```
ホゲは 1
試す
　1を 足す
　ホゲは それ
　ホゲを 0で 割る     ※ 例外が発生
　「おっはー」と 言う ※ この行は実行しない

ホゲを 表示する       ※ ここから続いて、「2」が表示
```

例外が発生した場合、そのエラーメッセージが特別変数`例外`に代入されます。その後、例外の存在を条件として例外処理が行えます。`試す`のブロックが無事に終わったら、`例外`の値はヌルとなります。

例）

```
試す
　「エラー！」を 投げる

もし 例外が あれば
　例外を 表示する
```

----

## 関数について

### 関数の定義

関数の定義は次のようなフォーマット：`【引数（任意）】 【関数名】とは`。

関数名は動詞（又は動詞句）で、同じスコープに重複の定義（ビルトイン関数も含む）は出来ません（※）。関数の中身は一個のホワイトスペース（全角・半角スペースまたはタブ）のインデントが必要です。詳しくは「[インデント](#インデント)」より参照してください。反復内には関数の定義が不可能です。

引数との助詞の指定も必要です。助詞は引数名に含まれません。使用可能助詞は`から`、`で`、`と`、`に`、`へ`、`まで`、`を`。

例）

```
友達と 食べ物を 道具で 食べるとは
　・・・
```

上記の`食べる`という関数には、`友達`、`食べ物`、と`道具`という引数があります。

一部の組み込み関数以外、関数の引数はコピーとして渡されます（詳しくは「[ビルトイン関数](#ビルトイン関数組み込み関数)」より参照してください）。外に定義した変数の値は読み込むことが可能ですが、代入が不可能です。引数または変数名が外のに被る際、関数のスコープが別のコピーを使用します。関数呼出終了後まで残したい値があれば、返す（下記のセクション）または特別グローバル`あれ`に代入することが推薦です。詳しくは「[それ / あれ](#それあれ)」より参照してください。

※関数の引数が使う助詞もシグナチャーに含まれます。助詞が違えば、同じ関数名を重複定義することが出来ます。ビルトイン関数や特別なキーワードは例外です。

#### 関数の復帰

関数の復帰は意味や使い方に異なる複数の方法があります。

値を返すことは次のようなフォーマット：`【返り値】を 返す`又は`【返り値】と なる`。「返す」という前者を引数無しで使うと`それ`が返されます。「なる」という後者の引数が必要です。

返り値を指定せずに返ることは次のようなフォーマット：`返る` or `戻る`。使い分けは意味のみです。

`返る`や`戻る`など、返り値を指定していない際、ヌルが自動的に返されます。

どのキーワードもひらがなでも書けます。

### 関数の呼び出し

関数を単純に関数名で呼び出します。デフォルト値の引数が提供されない為、関数のシグナチャーには引数があれば、その引数を渡さなければなりません。

```
友達と 話すとは
　・・・

「金魚草さん」と 話す
```

関数の呼び出しの引数の助詞が関数の定義と異なる順番の場合には、引数が定義の順番通りに使われます。

例）

```
友達と 食べ物を 道具で 食べるとは
　・・・

「箸」で 「金魚草さん」と 「ふわふわ卵のヒレカツ丼」を 食べる
```

この為、意味不明的で奇妙な関数呼び出しが可能なので要注意です。

例）

```
一と 二に 三と 四を 混ぜるとは
　・・・

2に 4を 3と 1と 混ぜる
```

上記の呼び出しはかなり意味不明ながら、ちゃんと動作します。しかし、独自の助詞のある引数は期待通りに並んで渡されるのですが、2つもある「と」の助詞の引数は区別が付かないので呼び出した順番に渡されます。結果的に引数の順番は3、2、1、4となります。

「[変数について](#変数について)」に前述したとおり、呼び出した関数の戻り値が`それ`というグローバル変数に代入されます。

エラーが投げらた際には、ヌルが返されます（エラー投げの詳しくは「[約物（句読文字）](#約物句読文字)」より参照してください）。

### 活用（動詞の語形変化）

関数を定義するタイミングで、該当する「た形」と「て形」の活用も定義されます。五段動詞と一段動詞の区別が曖昧な為、「いる」と「える」で終わる動詞の場合には、両方の活用形が使えます。

例）

```
食べ物を 食べるとは
　・・・

「ふわふわ卵のヒレカツ丼」を 食べた
「もうひとつのヒレカツ丼」を 食べて
「まだまだヒレカツ丼」を 食べって ※不正な活用だが可能
```

区別が付かない活用の関数が定義されてしまうことはあります。その場合、構文解析のタイミングでエラーが投げられます。新しい関数の定義の最後にビックリマーク（全角・半角可能）を付けると、前に定義した関数の活用形を上書きします。上書きされても、前の関数の原形をそのまま呼び出すことが可能です。

```
商品を かうとは
　・・・

草を かるとは ※構文解析の時、エラー
　・・・

草を かるとは！ ※エラーなし　「かう」の活用形が上書きされる
　・・・

「芝生」を かう   ※「かう」の原形がまだ呼び出せる
「芝生」を かって ※「かる」に参照
```

こうしてビルトイン関数の活用形の上書きも可能ですが、非推薦です。

----

## 雑題

### インデント

インデントレベルはホワイトスペース文字数に対して数えられます。スクリプトのメインボディはインデントなしで、その下の関数定義・分岐・反復の中身は周りより一段階深くのが必要です。インデントのホワイトスペースは全角・半角スペースとタブの中では自由です。スパゲッティコードが好きな人なら選り取りも可能です。

入力機が有効なまま、スペースでインデント出来るので全角スペースは良いかもしれませんが、一バイトであるタブはそれぞれのエディターによって幅の表示が好きなように設定出来るので推薦です。

### 改行

ホワイトスペースが可能な所なら`\`を入力すると、改行を入れて次の行に続けることも可能です。`\`の後はホワイトスペースと改行のみ可能です。

### 無演算命令

Python の`pass`の同様に金魚草は`・・・`という無演算命令を提供しています。後回しの実装の為や空なブロックの意図を示す為に使われます。

### コメント

インラインコメントは`※`で始まります。

`(`と`)`に囲まれる文はブロックコメントとなります。全角カッコも使用可能です。

例）

```
予定は 「買い物」※本当はゲーセン

（仕様未定）
プロジェクトするとは
　・・・

（
　作者：金魚草さん
　日時：2018-01-01 09:00:00
　バージョン： 1.0.0
）
```

### 約物（句読文字）

#### ビックリマーク（感嘆符）

もういいや！とにかく動け！と思う時がありますね。関数の呼び出しの命令の最後にビックリマーク（全角・半角可能）を付けるとエラーが抑えられます（これに対する例外について、`投げる`という[組み込み関数](#ビルトイン関数組み込み関数)より参照してください）。

例）

```
食べ物を 食べるとは
　1を 0で 割る

「プラスチック」を 食べる　 ※エラー有り
「プラスチック」を 食べる！ ※エラー無し

「エラー」を 投げる！ ※ビックリマークあってもエラー有り
```

#### ハテナマーク（疑問符）

変数や関数の呼び出しの末尾にハテナマークを付けるとバリュー又は戻り値がブーリアン型にキャストされます（条件式での使い方に関しては「[条件分岐](#条件分岐)」より参照してください）。

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

配列の定義にもハテナマークが使えます。

```
ブーリアン型リストは 0？、1？、配列？、「」？、「あ」？、無？
※結果： 偽、真、偽、偽、真、偽
```

要注意：ここのハテナマークは等式計算のように見えますが、そうではなく、ブーリアン型キャストです。

```
ホゲは 1
ホゲは 2？ ※ホゲの値は「true」 - 1と2の比較ではなくて、2のブーリアン型キャスト
```

下記はブーライン型へのキャストの仕組み：

| 値             | ハテナマークの結果 |
| -------------- | ------------------ |
| 0              | 偽                 |
| 0以外          | 真                 |
| 空の配列       | 偽                 |
| 値を持つ配列   | 真                 |
| 空の文字列     | 偽                 |
| 字を持つ文字列 | 真                 |
| 無             | 偽                 |

ビックリマークが付いてない関数がエラーを投げた際、結果が偽となります。詳しくは上記のセクション「[ビックリマーク（感嘆符）](#ビックリマーク感嘆符)」より参照してください。

### スクリプト終了

トップレベルのスコープでしかスクリプト終了出来ません。キーワードと使い方は関数の復帰と同じです。詳しくは「[関数の復帰](#関数の復帰)」より参照してください。

値を返して終了する際、スクリプトの終了コードがデータ型に応じて決まります。

| データ型                     | 終了コード |
| ---------------------------- | ---------- |
| 数値                         | 整数の値   |
| 配列または文字列             | 要素の数   |
| ブーリアン型（真）           | 0          |
| ブーリアン型（偽）またはヌル | 1          |

### デバッグ

[語源](https://ja.wikipedia.org/wiki/バグ#語源)と同じように、`蛾`というコマンドが提供されています。このコマンドを使うと、その時点までのプログラム状態を全て出力します。ビックリマーク（全角・半角可能）を付けるとプログラムの実行が停止します。

一つの変数または値をそのまま出力するには、ビルトイン関数`データを ポイ捨てる`が使えます。ビックリマークを付けると、プログラムの実行が停止します。

ここのコマンドはデバグのコマンドラインオプションが有効の時のみ使用可能です。

### コマンドライン引数

コマンドライン引数は`引数列`という特別な変数から取得出来ます。最初の要素は常にスクリプトファイル名です。`引数列`が変更可能なので要注意です。

「-」で始まる引数がオプションとして間違える可能性はあるので、`--`で区切られます。

例）

```bash
$ ./snapdragon hoge.sd arg1 arg2
$ ./snapdragon hoge.sd --debug3 -- --オプションではない
```

### REPL

金魚草に`-i`または`--interactive`というオプションを渡すと、REPLモードが開始します。これでコマンドラインから直接に金魚草のコードを実行出来ます。このオプションは`-t`、`--tokens`とは一緒に使えません。

REPLモードでは、コードが直ぐに一行ずつ処理されます。ブロックを始める命令にも関わらず、そのまま処理されます。条件分岐や反復、関数定義などの命令を複数行での入力するには、複数行入力モードが使えます。バックスラッシュ（`\`）または円記号（`￥`）が行の末尾の文字として入力すると、複数行入力モードに変えます。空行を入力すると、一行入力モードに戻り、入力したブロックが処理されます。

例）

```
金魚草:1 > ホゲは 1
金魚草:2 > ホゲを　表示する
1
金魚草:3 > 繰り返す ※ 無限ループ
^C
金魚草:4 > （割り込みで停止）
金魚草:5 > ほげるとは￥
金魚草:6 * 　「こんにちは！\n」と　言う
金魚草:7 *
金魚草:8 > ほげる
こんにちは！
金魚草:9 >
```

一つの注意点：普段のスクリプトと違って、REPLモードでは[ビックリマーク（感嘆符）](#ビックリマーク（感嘆符）)を付けなくても既に
定義した関数を自由に上書き出来ます。他の関数と同じ活用形のある関数を呼ぶ場合には要注意です。

----

## ビルトイン関数（組み込み関数）

[ビルトイン関数（組み込み関数）](./ja/built_ins.md)

----

## キーワード索引

[キーワード索引](./ja/index.md)