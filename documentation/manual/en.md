[日本語](./ja.md)

## Contents

* [Variables](#Variables)
  * [Numbers](#Numbers)
  * [Strings](#Strings)
  * [Arrays](#Arrays)
  * [Booleans](#Booleans)
  * [Null](#Null)
  * [それ / あれ](#それ--あれ)
  * [Variable Properties](#Variable-Properties)
* [Control Structures](#Control-Structures)
  * [Conditional Branching](#Conditional-Branching)
  * [Multiple-Condition Branching](#Multiple-Condition-Branching)
  * [Looping](#Looping)
  * [Try-Catch](#Try-Catch)
* [Functions](#Functions)
  * [Defining Functions](#Defining-Functions)
  * [Calling Functions](#Calling-Functions)
  * [Conjugations](#Conjugations)
* [Misc](#Misc)
  * [Indentation](#Indentation)
  * [Line Breaks](#Line-Breaks)
  * [No-op](#No-op)
  * [Comments](#Comments)
  * [Punctuation](#Punctuation)
  * [Exit](#Exit)
  * [Debugging](#Debugging)
  * [Command-Line Arguments](#Command-Line-Arguments)
  * [Interactive Mode (REPL)](#Interactive-Mode-REPL)
* [Built-in Functions](#Built-in-Functions)
* [Keyword Index](#Keyword-Index)

----

## Variables

Variables are declared using the following format: `[variable name]は [value]`.

Example:

```
ホゲは 1
```

This creates a variable `ホゲ` with the value `1`.

Variable names are generally unrestricted, with the exception of names containing illegal characters: `\` (backslash; see the section on "[Line Breaks](#Line-Breaks)" for more detail), `￥ｎ` (two-character jpy + 'ｎ'), `【`, and `】`). Note that properties will take precedence over variables with property-like names. See [Array / String Properties](#Array--String-Properties) for more information.

Variables must be declared with initial values. Values can also be used directly as parameters to function calls.

### Numbers

A number follows the format `/-?(\d+\.\d+|\d+)/` (ie. negatives and floating points allowed). Numbers may also be written in full-width characters.

Example:

```
ホゲは -3.14
```

The largest absolute number is undefined.

### Strings

A string is encompassed by the characters `「` (start) and `」` (end).

Example:

```
ホゲは 「もじれつ」
```

You can escape the closing character by prefixing it with a backslash.

Example:

```
ホゲは 「文字列の中の「もじれつ\」」
```

Strings may span multiple lines. Trailing and leading whitespace, including newlines, will be stripped. You can insert a newline using `\n` or `￥ｎ`. Prepend an additional `\` to avoid a newline.

```
作文は 「こんにちは。
         今日の予定は特になし。
         週末にカツ丼を食べに行く。」

「カツ丼が好き。￥ｎ
　毎日食べても飽きない。」を 言う
```

#### String Interpolation

You can interpolate variables or properties in a string by wrapping them in "black lenticular brackets" (【 and 】). Prepend a backslash (`\`) to escape the opening bracket.

Example:

```
名前は 「世界」
「こんにちは【名前】！」を 言う
```

The substitution in string interpolation cannot contain primitive values or strings which themselves contain interpolated variables.

Example:

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

Booleans `True` and `False` will be formatted as `はい` and `いいえ` respectively. Null will become an empty string.

Strings can, in a sense, be considered as an array of characters. For more information on accessing individual characters of a string, see the section on [Associative Arrays](#associative-arrays-aka-hashes-dictionaries).

### Arrays

An array is a list of values delimited by commas (full-width `、` or half-width `,`).

Example:

```
ホゲは 1、2、3
フガは 1,2,3
ピヨは 「あ」、「い」、「う」、1、2、3、ホゲ
```

You can also declare an empty array with the keyword `配列` or `連想配列` (see the next section for more information on associative arrays).

Example:

```
ホゲは 配列
```

For long lists, you may break the array into multiple lines after the comma:

```
母音は 「あ」、
　　　 「い」、
　　　 「う」、
　　　 「え」、
　　　 「お」
```

Like multi-line strings, spacing is not important, but you can realign items using a backslash if you want consistent indentation. See the section on "[Line Breaks](#Line-Breaks)" for more detail.

```
参加者は \
　「ウイ」、
　「チャールス」、
　「ジャック＆
　　アジューラ」
```

#### Associative Arrays (aka Hashes, Dictionaries)

All arrays (and strings) can be treated like associative arrays.

Element access follows the format: `[variable]の [accessor]`.

There are three ways of accessing array elements:

* Numeric index: `[integer][counter]目`, where available counters are: `つ`, `人`, `個`, `件`, `匹`, and `文字`. Example: `ホゲの 1つ目`
* Key name: a simple string which may include interpolation. Example: `ホゲの 「キー名」`
* Key variable: any previously-defined variable, including special globals `それ` and `あれ`. Example: `ホゲの 変数`

Numeric indices are 1-based, due to the semantic meaning in Japanese. The first element (0th index) is "1つ目", there is no "0つ目". However, accessing the array by key name or variable is 0-based as usual.

Accessing an array with a non-existent key (or out-of-bounds) will return null.

You may have noticed that this means that arrays can be accessed by either numeric or string keys. In fact, all keys are stored internally as "(floated) strings". The following accessors are all equivalent:

```
ホゲの 1つ目

ホゲの 「0」

ホゲの 「0.0」

整数の指数は 0
ホゲの 整数の指数

浮動小数点の指数は 0.0
ホゲの 浮動小数点の指数
```

In the case of strings, the keys must be numeric and within the length of the string.

```
「ホゲ」の １つ目 ※ OK

「ホゲ」の 「0」  ※ OK

文字の位置は 0
「ホゲ」の 文字の位置 ※ OK

「ホゲ」の 「キー名」 ※ NG
```

Unlike most other cases involving numerics, full-width numbers are not treated like half-width numbers within key names. The following are not equivalent:

```
ホゲの 「0」

ホゲの 「０」
```

Assigning array elements with other types of variables as keys will stringify them. In particular, `True` and `False` will be stringified as `はい` and `いいえ`, respectively, and null is treated as an empty string.

Newly added elements will generally remain in insertion order, with new key values taking the next consecutive integer key following the largest numeric key.

Example:

```
例の配列は 連想配列
例の配列の 1つ目は    「あ」 ※ {0: "あ"}
例の配列の 「ほげ」は 「い」 ※ {0: "あ", "ほげ": "い"}
例の配列の 「4.6」は  「う」 ※ {0: "あ", "ほげ": "い", 4.6: "う"}
例の配列の 「ふが」は 「え」 ※ {0: "あ", "ほげ": "い", 4.6: "う", "ふが": "え"}
例の配列に 「お」を 押し込む ※ {0: "あ", "ほげ": "い", 4.6: "う", "ふが": "え", 5: "お"}
```

Because elements can be added freely with any numeric index, `先頭から押し込む` and `先頭を引き出す`, which explicitly modify the front of the array, will cause numeric keys to be renumbered. `抜く` and other functions which may modify arrays at any point, will not renumber keys.

Example:

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

In the case of concatenation:

* All numeric indices in the source array are renumbered starting from last numeric index of the target array
* If any string keys in the source array are also present in the target array, the values of the source array will overwrite those in the target array
* Otherwise, target arrays keys and insertion order are retained

Example:

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

While this may seem complicated at first, in practice it is usually not common to mix numeric and string keys.

### Booleans

| Boolean | Supported Keywords         |
| ------- | -------------------------- |
| True    | `真`, `肯定`, `はい`, `正` |
| False   | `偽`, `否定`, `いいえ`     |

### Null

Supported keywords: `無`, `無い`, `無し`, `ヌル`

### それ / あれ

Like [なでしこ](https://ja.wikipedia.org/wiki/なでしこ_%28プログラミング言語%29), `それ` is a special global variable equal to the value of the last-executed statement.

Similarly, `あれ` is another special global variable. Use it as you like!

### Variable Properties

Various properties can be retrieved using the following format: `[variable]の [property]`. Presently, only Numeric-, String-, and Array-type variables can have properties. String primitives can also be used in place of variables. Properties-of-properties are not supported.

Below is a list of properties available:

| Property | Applicability  | Assignable? | Details |
| -------- | -------------- | ----------- | ------- |
| 長さ     | 配列 or 文字列 | No          | Returns the length of the object |
| キー列   | 配列 only      | No          | Returns an array of keys belonging to the array |
| 先頭     | 配列 or 文字列 | Yes         | References the first element of the array or the first character of the string<br>Returns null if the array is empty or an empty string if the string is empty |
| 末尾     | 配列 or 文字列 | Yes         | References the last element of the array or the last element of the string<br>Returns null if the array is empty or an empty string if the string is empty |
| 先頭以外 | 配列 or 文字列 | No          | Returns an array containing all elements of the array or all characters of the string, excluding the first<br>Returns an empty array if the array is empty or an empty string if the string is empty |
| 末尾以外 | 配列 or 文字列 | No          | Returns an array containing all elements of the array or all characters of the string, excluding the last<br>Returns an empty array if the array is empty or an empty string if the string is empty |
| 〇乗     | 数値           | No          | Returns the value raised to the power of 〇<br>〇 must also be a number primitive |
| 〇乗根   | 数値           | No          | Returns the 〇th root of the value<br>〇 must also be a number primitive |

The length property can additionally be accessed by `ながさ`, `大きさ`, `おおきさ`, `数`, `かず`, `人数`, `個数`, `件数`, `匹数`, `文字数`.

The key array property can additionally be accessed by `インデックス`.

The power and root properties may also be calculated with `その乗` or `その乗根`, which use the value of the global `それ`. `あの乗` and `あの乗根` use `あれ`. Additionally, `平方` and `自乗` alias `２乗` (squared power) while `平方根` and `自乗根` alias `２乗根` (squared root). For calculating logarithm, see the section on "[Math](#Math)".

Example:

```
チームは 「アジューラ」、「チャールス」、「ウイ」
チームの 「サポート」は 「ニッキー」
チームの 「リーダー」は 「セフ」
チーム名は 「T4O」

チームの 長さを 表示する ※ 5
チームの 人数を 表示する ※ also OK

チーム名の 文字数を 表示する ※ 3
チーム名の 匹数を 表示する   ※ strange, but valid

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

## Control Structures

### Conditional Branching

A conditional branch follows the format `もし [conditional statement]`. The body must be indented one whitespace character (full-width or half-width space or tab; see the section on "[Indentation](#Indentation)" for more detail).

The conditional statement is generally comprised of three parts: "subject", "comparator 1", and "comparator 2".

The "subject" follows the format `[variable or value]が`. This variable or value is the first operand.

"Comparator 1" is a variable or value (the second operand) optionally followed by one of `と 同じ`, `より`, `以上`, or `以下`.

"Comparator 2" is one of `ならば`, `なら`, `大きければ`, `小さければ`, according to semantics. `ならば`, `なら`, and `であれば` are functionally equivalent.

"Comparator 1" and "comparator 2", together, form the logical operator, and follow the format: `[variable or value][comparator 1] [comparator 2]`.

Below is a chart of various comparisons between two variables, `Ａ` and `Ｂ`:

| Comparison                         | Logical Operation |
| ---------------------------------- | ----------------- |
| もし　Ａが　Ｂと　同じ　ならば     | `Ａ == Ｂ`        |
| もし　Ａが　Ｂより　大きければ     | `Ａ > Ｂ`         |
| もし　Ａが　Ｂより　小さければ     | `Ａ < Ｂ`         |
| もし　Ａが　Ｂ以上　ならば         | `Ａ >= Ｂ`        |
| もし　Ａが　Ｂ以下　ならば         | `Ａ <= Ｂ`        |
| もし　Ａが　Ｂ　　　ならば         | `Ａ == Ｂ`        |

Any condition using `ならば` or `なら` may be reversed with `でなければ` or `じゃなければ`, both of which are functionally equivalent.

| Comparison                         | Logical Operation |
| ---------------------------------- | ----------------- |
| もし　Ａが　Ｂと　同じ　でなければ | `Ａ != Ｂ`        |
| もし　Ａが　Ｂ以上　でなければ     | `Ａ < Ｂ`         |
| もし　Ａが　Ｂ以下　でなければ     | `Ａ > Ｂ`         |
| もし　Ａが　Ｂ　でなければ         | `Ａ != Ｂ`        |

If `Ａ` and `Ｂ` are different types, the comparison result will always be false (unless the comparison is `!=`).

"Comparator 2" can be written in plain ひらがな as well (without kanji).

Example:

```
もし Ａが Ｂと おなじ ならば
　・・・

もし Ａが Ｂより おおきければ
　・・・
```

Additionally, `大きければ` and `少なければ` have several aliases (for semantic purposes).

| Greater Than (>) | Less Than (<) |
| ---------------- | ------------- |
| 大きければ       | 小さければ    |
| 長ければ         | 短ければ      |
| 高ければ         | 低ければ      |
| 多ければ         | 少なければ    |

Of course, these can also be written in plain ひらがな. Note that `大きくなければ` and `小さくなければ` are not supported, as these can be written as `以下 ならば` and `以上 ならば` respectively.

#### Truthy Check

You may also append a question mark (full-width `？` or half-width `?`) to a single value to use its "truthy-ness" as a condition. The associated "comparator 2" is either `ならば` or `でなければ`.

| Condition              | Logical Operation |
| ---------------------- | ----------------- |
| もし　Ａ？　ならば     | `Ａ`              |
| もし　Ａ？　でなければ | `!Ａ`             |

See the section on "[Question Mark](#Question-Mark)" for more detail.

While functionally similar, an alternate "existence check" version is available for semantics: `もし Aが あれば`. This can be negated with `なければ`.

#### Empty Check

While emptiness can be checked by comparing an array or string's length to `0`, you may also compare a container with `空` to use its emptiness as a condition. ひらがな `から` is also available.

Example:

```
もし 何かの配列の 長さが 0 ならば

※ is equivalent to

もし 何かの配列が 空 ならば
```

If the subject is not a string or array, the condition will always be false.

#### Inside Check

The existence of a value within a string or array may also be used as a condition, using the following format: `もし [variable or value]が [container]の 中に あれば`.

Example:

```
もし 「リュウ」が 「ハオ　リュウ」の 中に あれば
　・・・

もし 私の 大好物が メニューの 中に あれば
　・・・
```

Use `なければ` to reverse the condition.

If the container is a string and the value is not a string, the condition will always be false.

#### Type Check

Generally, the keyword `配列` is treated as an empty array. However, when used as the second value of a `==` or `!=` comparison, a type check is performed instead.

Example:

```
Ａは 1、2、3
Ｂは 「こんにちは」

もし Ａが 配列 ならば # true
　・・・

もし Ｂが 配列 ならば # false
　・・・

もし 配列が Ａ ならば # false - not a type check
　・・・

もし Ａが 配列より 大きければ # true - 配列 is an empty array
　・・・
```

This is useful for differentiating between strings and arrays, as most built-ins treat them similarly despite not being interchangeable.

#### Function Calls As Conditions

In addition to the three-part conditional statement, function calls followed by `ならば` can also be used as conditions. They may be optionally suffixed with [punctuation](#Punctuation), however the result will be boolean-cast regardless.

Example:

```
もし 「ふわふわ卵のヒレカツ丼」を 食べた？ ならば
　・・・
```

To reverse the condition, use `でなければ`.

#### ELSE IF and ELSE

Following an if-statement, an else-if or an else-statement can be added at the same indentation level as the initial if-statement.

The else-if statement follows the format `もしくは [conditional statement]` or `または [conditional statement]` where the conditional statement is as described in the previous section. Multiple else-ifs are allowed.

The else statement is a single keyword with no condition, however there are many available aliases for flavour: `それ以外ならば`, `それ以外なら`, `それ以外は`、`それ以外だと`, `でなければ`, `じゃなければ`, `違うならば`, `違うなら`, and `違えば`. The last three may also be written in ひらがな.

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

### Multiple-Condition Branching

If-statements may contain multiple conditions. The final condition follows the same format as before, while each preceding condition's "Comparator 2" takes a "conjunctive form" (or is omitted in certain cases), followed by a comma and a conjunctive logical operator (see section below).

| Normal Comparison / Condition    | Conjunctive Form                     |
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

In the conjunctive form, most conditions are followed by the copula `であり`. These can be negated by `でなく`. Aliases `で` and `じゃなく` are also available.

Example:

```
もし 時間が 「12：00」 で、人数が 1以上 ならば
　パーティーを 始める
```

For truthy checks and functional conditions, no copula is required in the positive case:

| Normal Comparison / Condition | Conjunctive Form           |
| ----------------------------- | -------------------------- |
| もし　Ａ？　　　　　ならば    | もし　Ａ？、...            |
| もし　関数呼び出す？　ならば  | もし　関数呼び出す？、 ... |

These may still be negated with `でなく`.

The alternate "existence check" ending in `あれば` and `なければ` becomes `あり` and `なく`, respectively.

| Normal Condition       | Conjunctive Form      |
| ---------------------- | --------------------- |
| もし　Ａ？　ならば     | もし　Ａが　あり、... |
| もし　Ａ？　でなければ | もし　Ａが　なく、... |

Because a phrasing such as `関数呼び出す？ でなく` sounds unnatural, `なく` is available as another alias. When combined with functional name conjugation and question mark being optional, this allows the phrasing `関数呼び出して なく`.

Also important to note: because functional conditions have their result reflected in the special variable `それ`, multiple functional conditions chained together will each modify `それ` in turn.

Example:

```
それは 1
もし 1を 足して、且つ 2を 足す ならば
　それを 表示する ※ 4 is displayed
```

#### Conjunctive Logical Operators

Snapdragon provides only two simple logical operators: `AND` and `OR`.

These follow the comma in conjunctive conditions: `もし [conjunctive conditional statement]、[AND / OR] [conditional statement]`.

`AND` is written as `且つ` or `かつ`, while `OR` is written as `又は` or `または`.

As with most languages, `AND` has a higher precedence compared to `OR`. This is especially important in the following example.

Given `A | B & C` with values `A = 1`, `B = 0`, `C = 0`:

```
A | B & C
1 | 0 & 0 ※ substitute values
1 | 0     ※ AND is performed first
1
```

Now consider an example like, "can a customer purchase this item?" and replace `A`, `B`, and `C` with `item_reserved`, `item_in_stock`, and `customer_has_money`.

```
※ can a customer purchase this item?
item_reserved | item_in_stock & customer_has_money
1 | 0 & 0 ※ substitute values
1 | 0     ※ AND is performed first
1         ※ yes?
```

In this case, the previous result doesn't make sense; the customer has no money yet is able to purchase the item. The expected result is only achieved if we parenthesize `(A | B)`:

```
※ can a customer purchase this item?
(item_reserved | item_in_stock) & customer_has_money
(1 | 0) & 0 ※ substitute values
1 & 0       ※ OR is performed first
0           ※ no
```

However, Snapdragon does not allow the use of parentheses for forcing particular operation orders. While this makes performing certain conditionals more difficult, it also forces writers to them shorter and clearer.

Below are two options for achieving the correct result:

Option 1: nest the condition

```
もし 予約あり？、又は 在庫あり？ ならば
　もし ユーザの 残高が 0以上 ならば
　　・・・
```

Option 2: extract the OR condition into a helper

```
商品があるとは
　もし 予約あり？、又は 在庫あり？ ならば
　　はいと なる

もし 商品がある？、且つ ユーザの 残高が 0以上 ならば
```

### Looping

The looping keyword is `繰り返す`. This can be written with any combination of kanji or ひらがな.

There are two ways to perform looping: with (optional) start and end parameters, or over a container object.

A loop can be immediately exited using the keyword `終わり` or an iteration can be skipped with `次`. Both can be written in ひらがな.

Loop bodies must be indented one whitespace character (full-width or half-width space, or tab; see the section on "[Indentation](#Indentation)" for more detail).

#### With Parameters

A simple loop must either use two parameters (start and end) or no parameters (an infinite loop unless manually broken). It follows the format `[optional parameters] 繰り返す`.

If using two parameters, they must be either variables or numeric primitives. Note that variables should be numeric, but there is no safety check for this. Floats will be cast to integers. The parameters must also use the particles から and まで to specify start and end (inclusive), respectively, however the order does not matter. To loop backwards, simply swap the start and end values.

Example:

```
1から 100まで 繰り返す
　・・・

繰り返す
　「無限ループ？」を 言う
　終わり
```

##### Short Static Loop

A short static loop is also available with the format `[number]回 繰り返す`. This is simply shorthand for `1から [number]まで 繰り返す`.

#### Over An Object

Looping over an object is done using the format `[object]に 対して 繰り返す`. The object must be either an array-type variable or a string, although there is no safety check for the former. `対して` may also be written in ひらがな.

Example:

```
買い物リストに 対して 繰り返す
　アイテムは それ
　もし アイテムを 既に買った？ ならば
　　次
　違えば
　　アイテムを 買う
```

#### While Loop

Using conditional expressions like If-statements, it's possible to loop while a specified condition is true.

The single or last of multiple conditions takes an "attributive form" preceding `限り` (or `かぎり` in ひらがな) and `繰り返す`. The full format is as follows: `[conjunctive conditional statement]、[AND / OR] [attributive conditional statement] 限り 繰り返す`.

| Normal If Comparison / Condition   | Attributive Form                           |
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

In the attributive form, most conditions are followed by the copula `である`. These can be negated by `でない` or `じゃない`.

For truthy conditions, whether the result should be true or false must be specified. The "existence check" ending in `あれば` or `なければ` takes the form `ある` or `ない`, respectively.

| Normal If Comparison / Condition | Attributive Form             |
| -------------------------------- | ---------------------------- |
| もし　Ａ？　ならば               | Ａ？　真の　[限り　繰り返す] |
| もし　Ａ？　ならば               | Ａが　ある　[限り　繰り返す] |
| もし　Ａ？　でなければ           | Ａ？　偽の　[限り　繰り返す] |
| もし　Ａ？　でなければ           | Ａが　ない　[限り　繰り返す] |

The attributive form of functional conditions is similar to conjunctive form. No copula is required in the positive case, and a negated case may use `でない`, or `ない` for natural flow.

| Normal If Comparison / Condition | Attributive Form                       |
| -------------------------------- | -------------------------------------- |
| もし　関数呼び出す？　ならば     | 関数呼び出す　　　　　[限り　繰り返す] |
| もし　関数呼び出す？　でなければ | 関数呼び出して　ない　[限り　繰り返す] |

Example:

```
回数は 0
回数が 10より 小さい 限り 繰り返す ※ loops 10 times
　回数に 1を 足す
　回数は それ
```

While regular loop ranges may be "dynamic" in the sense that they can be defined by variables at runtime, the range is only computed once. Even if the boundary variables' values change, the number of loop iterations will not. In contrast, while loops have their condition re-calculated each time. This means that while loop conditions containing functions will cause `それ` to be extremely volatile.

Example:

```
それは 0

1を 足す 限り 繰り返す ※ loops forever
　それを 表示する      ※ continually outputting それ

1を 足す 限り 繰り返す ※ loops once
　「【それ】」と 言う  ※ それ becomes a string and the next iteration's condition throws an error
```

### Try-Catch

A "try" block can be started with the keyword `試す` or `ためす`.

The body must be indented one level. If an error occurs, execution will be stopped immediately and will resume from the end of the try block.

Example:

```
ホゲは 1
試す
　1を 足す
　ホゲは それ
　ホゲを 0で 割る     ※ an error occurs here
　「おっはー」と 言う ※ this code is not executed

ホゲを 表示する       ※ execution resumes here and "2" is displayed
```

While there is no exact "catch" construct, an error that occurs within the `試す` block will have its message stored in a special variable `例外`. This error variable may then be checked and handled appropriately. If a try block completes with no error, `例外` will be null.

Example:

```
試す
　「エラー！」を 投げる

もし 例外が あれば
　例外を 表示する
```

----

## Functions

### Defining Functions

Functions are declared using the following format: `[optional parameters] [function name]とは`.

Function names must be verbs (or verb phrases) and cannot be redeclared※ within the same scope (this includes collisions with built-in function names). Function bodies must be indented one whitespace character (full-width or half-width space, or tab; see the section on "[Indentation](#Indentation)" for more detail). Functions may not be defined within loops.

Parameters are each suffixed with one of the following particles: `から`, `で`, `と`, `に`, `へ`, `まで`, `を`. The particles are not part of the parameter names.

Example:

```
友達と 食べ物を 道具で 食べるとは
　・・・
```

This function, "食べる" takes three parameters: "友達", "食べ物", and "道具".

Parameters are passed by value, with the exception of a few specific built-in functions (see the section on "[Built-In Functions](#Built-In-Functions)" for more detail). Variables defined within outer scopes may be read, but cannot be written to. If a parameter or function variable shadows an outer variable, the function scope will retain its own copy. If you require values to persist after a function call, they must either be returned (described below) or stored in the special global `あれ` (see the section on "[それ / あれ](#それ--あれ)" for more detail).

※ The particles used to define the function become part of its signature. A function with the same name can be redeclared as long as its signature is different (overloading), with the exception of built-ins and special keywords.

#### Returning

There are multiple ways to return with differences in both semantics and functionality.

You can return a value using the following formats: `[返り値]を 返す` or `[返り値]と なる`. The former, "返す", can be used without a parameter and will implicitly return `それ`. The latter must have a parameter.

You can return without specifying a value using the following formats: `返る` or `戻る`. These differ in only semantics.

In the case of `返る`, `戻る`, or when a function has no return, the actual return value will be null.

Any of these keywords may be written in ひらがな.

### Calling Functions

A function is simply called by its name (with any associated parameters, if applicable). If a function signature contains parameters, a function call must supply them (no default parameters).

```
友達と 話すとは
　・・・

「金魚草さん」と 話す
```

A function definition's parameter order will be preserved according to their particles even if a function call's parameters are in a different order.

Example:

```
友達と 食べ物を 道具で 食べるとは
　・・・

「箸」で 「金魚草さん」と 「ふわふわ卵のヒレカツ丼」を 食べる
```

Be careful because this does allow for semantically strange function calls.

Example:

```
一と 二に 三と 四を 混ぜるとは
　・・・

2に 4を 3と 1と 混ぜる
```

While this function call makes very little sense, it will be parsed successfully. However, while parameters with unique particles will be ordered as expected, the two parameters with と particles cannot be differentiated and will be passed in calling order. Thus, the resultant parameter order will be 3, 2, 1, 4.

As mentioned in the section on "[Variables](#Variables)", a function's return value will be available via the global variable `それ`.

Functions which throw an error will naturally return null (see the section on "[Punctuation](#Punctuation)" for allowing error-throwing).

### Conjugations

When a function is defined, its た-form (aka "perfective", "past tense") and て-form (aka "participle", "command") conjugations also become available. Verbs ending with いる and える are difficult to distinguish between 五段動詞 and 一段動詞 so both conjugations are available (just in case!).

Example:

```
食べ物を 食べるとは
　・・・

「ふわふわ卵のヒレカツ丼」を 食べた
「もうひとつのヒレカツ丼」を 食べて
「まだまだヒレカツ丼」を 食べって ※Incorrect but usable
```

Some verbs may end up having ambiguous conjugations. In this case, an error will be thrown during parsing. You may append an exclamation mark (full-width `！` or half-width `!`) to the function definition to allow subsequent functions to overwrite the conjugations of previously-defined functions. The base form of the previously-defined functions will still be usable.

```
商品を かうとは
　・・・

草を かるとは ※This will throw an error during parsing
　・・・

草を かるとは！ ※No error - overrides conjugations of かう
　・・・

「芝生」を かう   ※かう is still callable
「芝生」を かって ※Refers to かる instead of かう
```

By doing this, it is possible to overwrite the conjugated forms of built-in functions, although this is not recommended.

----

## Misc

### Indentation

Indentation is determined by the number of whitespace characters. The main body of the script must not be indented, and each subsequent body of functions, if-statements, or loops must be indented one level deeper than its parent. However the type of indentation may be full-width or half-width spaces or tabs, or a mixture (for those who enjoy illegible spaghetti).

Full-width spaces may be preferred as it makes indentation easy with a Japanese input method editor enabled, however tabs are recommended. Tabs have the benefit of being single byte characters while also having their display width freely configurable for each developer's preference.

### Line Breaks

Anywhere whitespace is allowed, you may insert a `\` and continue on the following line. The `\` must be followed by only whitespace or a newline.

### No-op

Like Python's `pass`, Snapdragon provides `・・・` as a no-op. You can use it to stub functions for later implementation, or to signify an intentionally-empty block.

### Comments

Plain inline comments are prefixed with `※`.

Block comments are encompassed by parentheses `(` and `)`. Full-width parentheses `（` and `）` are also usable.

Example:

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

### Punctuation

#### Exclamation Mark / Bangs

Sometimes you just want the code to do what it's told without caring about the consequences. Suffixing a function call with an exclamation mark (full-width `！` or half-width `!`) will cause all errors to be suppressed (see the [built-in](#Built-in-Functions) `投げる` for an exception to this).

Example:

```
食べ物を 食べるとは
　1を 0で 割る

「プラスチック」を 食べる　 ※ error is thrown
「プラスチック」を 食べる！ ※ error is suppressed

「エラー」を 投げる！ ※ error is thrown regardless
```

#### Question Mark

A variable or function call suffixed with a question mark (full-width `？` or half-width `?`) will have its value or return value cast to a boolean (see the section on "[Truthy Check](#Truthy-Check)" for use within conditional statements).

Example:

```
食べ物を 食べるとは
　・・・

「ふわふわ卵のヒレカツ丼」を 食べた？
ホゲは それ
```

This is equivalent to

```
「ふわふわ卵のヒレカツ丼」を 食べる
ホゲは それ？
```

Lists may also contain boolean-cast variables:

```
ブーリアン型リストは 0？、1？、配列？、「」？、「あ」？、無？
※Result: false, true, false, false, true, false
```

It is important to remember that this use of question mark is a boolean cast and not a calculation of equality.

```
ホゲは 1
ホゲは 2？ ※ホゲ is true - it is not a comparison of 1 and 2, but a boolean cast of 2
```

Below is a list of how different values are cast:

| 値               | ハテナマークの結果 |
| ---------------- | ------------------ |
| 0                | 偽                 |
| non-0            | 真                 |
| empty array      | 偽                 |
| non-empty array  | 真                 |
| empty string     | 偽                 |
| non-empty string | 真                 |
| null             | 偽                 |

If a function call without a bang suffix throws an error, the result will be false. See the previous section "Exclamation Mark / Bangs" for more detail.

### Exit

You can exit a script only from the main scope. The keyword and functionality is the same as returning. See the section on "[Returning](#Returning)" for details.

When returning a value, the script's exit code will be determined based on the data type.

| Data Type               | Exit Code          |
| ----------------------- | ------------------ |
| Number                  | Integer-cast value |
| Array or String         | Length             |
| Boolean (True)          | 0                  |
| Boolean (False) or Null | 1                  |

### Debugging

Like the "[original bug](https://en.wikipedia.org/wiki/Software_bug#History)", you can use the command `蛾` to dump the entire program state (up until that point). Followed by a bang (full-width `！` or half-width `!`), this will cause execution to stop.

To print a single variable or value as-is, use the built-in function `データを ポイ捨てる`. Followed by a bang, this will cause execution to stop.

These commands are only executed if the command line option for debugging is enabled.

### Command-Line Arguments

Command-line arguments can be accessed by a special variable `引数列`. The first argument will always be the name of the script. Note that `引数列` is mutable.

As arguments beginning with "-" may be confused as options, you can use `--` to separate them.

Example:

```bash
$ ./snapdragon hoge.sd arg1 arg2
$ ./snapdragon hoge.sd --debug3 -- --not-an-option
```

### Interactive Mode (REPL)

Using Snapdragon with the option `-i` or `--interactive` will enter Interactive Mode (REPL). This will let you execute Snapdragon code from the command line. This mode cannot be used alongside the `-t` or `--tokens` option.

In Interactive Mode, each line will be executed immediately -- including lines which would normally begin blocks. In order to input multi-line blocks such as if-statements, loops, or function definitions, you may enter a single backslash `\` or `￥` as the last character of the line to begin multi-line input mode. Entering a blank link will cut the input and execute.

Example:

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

One quirk regarding Interactive Mode -- unlike regularly executed Snapdragon scripts, functions may be freely re-defined regardless of whether or not you append a bang ([Exclamation Mark / Bangs](#Exclamation-Mark--Bangs)). Thus extra care should be taken when calling methods with ambiguous conjugations.

----

## Built-in Functions

[Built-Ins](./en/built_ins.md)

----

## Keyword Index

[Index](./en/index.md)