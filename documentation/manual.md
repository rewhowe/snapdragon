[日本語](./manual_jp.md)

## Contents

* [Variables](#Variables)
  * [Numbers](#Numbers)
  * [Strings](#Strings)
  * [Arrays](#Arrays)
  * [Array / String Properties](#Array--String-Properties)
  * [Booleans](#Booleans)
  * [Null](#Null)
  * [それ / あれ](#それ--あれ)
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
* [Built-in Functions](#Built-in-Functions)
  * [Output](#Output)
  * [Formatting](#Formatting)
  * [String / Array Operations](#String--Array-Operations)
  * [Math](#Math)
  * [Miscellaneous](#Miscellaneous)

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

### Array / String Properties

Properties belonging to arrays and strings can be retrieved using the following format: `[variable]の [property]`. String primitives can also be used in place of variables.

Below is a list of properties available:

| Property | Applicability  | Assignable? | Details |
| -------- | -------------- | ----------- | ------- |
| 長さ     | 配列 or 文字列 | No          | Returns the length of the object |
| キー列   | 配列 only      | No          | Returns an array of keys belonging to the array |
| 先頭     | 配列 or 文字列 | Yes         | References the first element of the array or the first character of the string<br>Returns null if the array is empty or an empty string if the string is empty |
| 末尾     | 配列 or 文字列 | Yes         | References the last element of the array or the last element of the string<br>Returns null if the array is empty or an empty string if the string is empty |
| 先頭以外 | 配列 or 文字列 | No          | Returns an array containing all elements of the array or all characters of the string, excluding the first<br>Returns an empty array if the array is empty or an empty string if the string is empty |
| 末尾以外 | 配列 or 文字列 | No          | Returns an array containing all elements of the array or all characters of the string, excluding the last<br>Returns an empty array if the array is empty or an empty string if the string is empty |

The length property can additionally be accessed by `ながさ`, `大きさ`, `おおきさ`, `数`, `かず`, `人数`, `個数`, `件数`, `匹数`, `文字数`.

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
```

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

----

## Control Structures

### Conditional Branching

A conditional branch follows the format: `もし [conditional statement]`. The body must be indented one whitespace character (full-width or half-width space or tab; see the section on "[Indentation](#Indentation)" for more detail).

The conditional statement is generally comprised of three parts: "subject", "comparator 1", and "comparator 2".

The "subject" follows the format: `[variable or value]が`. This variable or value is the first operand.

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

The else-if statement follows the format: `もしくは [conditional statement]` or `または [conditional statement]` where the conditional statement is as described in the previous section. Multiple else-ifs are allowed.

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
| もし　Ａが　Ｂより　大きく       | もし　Ａが　Ｂより　大きく、 ...     |
| もし　Ａが　Ｂより　小さければ   | もし　Ａが　Ｂより　小さく、 ...     |
| もし　Ａが　Ｂ以上　ならば       | もし　Ａが　Ｂ以上　であり、 ...     |
| もし　Ａが　Ｂ以下　ならば       | もし　Ａが　Ｂ以下　であり、 ...     |
| もし　Ａが　Ｂ　　　ならば       | もし　Ａが　Ｂ　　　であり、 ...     |
| もし　Ａが　空　　　ならば       | もし　Ａが　空　　　であり、 ...     |
| もし　Ａが　Ｂの　中に　あれば   | もし　Ａが　Ｂの　中に　あり、 ...   |
| もし　Ａが　Ｂの　中に　なければ | もし　Ａが　Ｂの　中に　なく、 ...   |

In the conjunctive form, most conditions are followed by the copula `であり`. These can be negated by `でなく`. Aliases `で` and `じゃなく` are also available.

For truthy checks and functional conditions, no copula is required in the positive case:

| Normal Comparison / Condition  | Conjunctive Form           |
| ------------------------------ | -------------------------- |
| もし　Ａ？　　　　　ならば     | もし　Ａ？、...            |
| もし　関数呼び出す？　ならば   | もし　関数呼び出す？、 ... |

These may still be negated with `でなく`.

Because a phrasing such as `関数呼び出す？ でなく` sounds unnatural, `なく` is available as another alias. When combined with functional name conjugation and question mark being optional, this allows the phrasing `関数呼び出して なく`.

Also important to note: because functional conditions have their result reflected in the special variable `それ`, multiple functional conditions chained together will each modify `それ` in turn.

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
もし ユーザの 残高が 0以上 ならば
　もし 予約あり？、又は 在庫あり？ ならば
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

### Try-Catch

(Planned for future versions)

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

----

## Built-in Functions

### Output

#### `言葉と 言う`, `言葉を 言う`

Prints `言葉` to stdout. `言葉を 言う` differs in semantics only.

| Parameters     | Return | ひらがな Allowed? |
| -------------- | ------ | ----------------- |
| `言葉`: String | `言葉` | Yes               |

#### `メッセージを 表示する`

Prints `メッセージ` to stdout. A newline will be appended.

| Parameters             | Return       | ひらがな Allowed? |
| ---------------------- | ------------ | ----------------- |
| `メッセージ`: Anything | `メッセージ` | No                |

#### `データを ポイ捨てる`

Dumps `データ` to stdout if debugging is enabled. Causes execution to stop if followed by a bang (full-width `！` or half-width `!`).

| Parameters         | Return   | ひらがな Allowed? |
| ------------------ | -------- | ----------------- |
| `データ`: Anything | `データ` | No                |

### Formatting

#### `フォーマット文に 引数を 書き込む`

Formats an array or variable `引数` into placeholders, signified by `〇`, within `フォーマット文`. Literal 〇 may be escaped by prepending them with a backslash `\`.

The number of placeholders must equal the number array elements of `引数`, or exactly 1 if `引数` is not an array.

Numeric parameters may be formatted by following `〇` with a parenthesized format string `A詰めB桁。C詰めD桁` (decimal may be full-width or half-width). The formatted string will be `A`-padded `B`-digits before the decimal and `C`-padded `D`-digits after the decimal. `A`, `C`, and `D` default to `0` if omitted. If `D` is `0`, the decimal will be removed. Digits before the decimal will not be truncated if longer than `B`.

A literal parenthesis following `〇` may be escaped by prepending it with a backslash `\`.

Example: `「〇（　詰め4桁.6桁）」に 49を 書き込む` yields `　　　4.900000`.

| Parameters                                   | Return               | ひらがな Allowed?        |
| -------------------------------------------- | -------------------- | ------------------------ |
| `フォーマット文`: String<br>`引数`: Anything | The formatted string | `書きこむ` or `かきこむ` |

#### `数値を 精度に 切り上げる`, `数値を 精度に 切り下げる`, `数値を 精度に 切り捨てる`

These three functions each perform slightly different operations.

* `切り上げる` - Rounds `数値` up to `N` figures.
* `切り下げる` - Rounds `数値` down to `N` figures.
* `切り捨てる` - Rounds `数値` to the closest `N` figures. (>=5 rounds up, <=4 rounds down)

`精度` must be a string of one of the following formats:

* When `精度` is `N桁`: rounds `数値` to N digits.
* When `精度` is `少数第N位` or `少数点第2位`: rounds `数値` to N decimal places.

| Parameters                       | Return             | ひらがな Allowed?                             |
| -------------------------------- | ------------------ | --------------------------------------------- |
| `数値`: Number<br>`精度`: String | The rounded number | Only `きりあげる`, `きりさげる`, `きりすてる` |

#### `変数を 数値化する`

Converts `変数` into its numeric equivalent according to following logic:

| Type   | Returns |
| ------ | ------- |
| Number | The number unchanged |
| String | The string parsed as a number; Throws an error if the string cannot be parsed |
| Array  | The length of the array |
| Other  | 1 if truthy, 0 if falsy |

| Parameters       | Return | ひらがな Allowed? |
| ---------------- | ------ | ----------------- |
| `変数`: Anything | Number | No                |

#### `変数を 整数化する`

Converts `変数` into its integer equivalent according to the following logic:

| Type   | Returns |
| ------ | ------- |
| Number | The number with its fractional portion removed |
| String | The string parsed as an integer; Throws an error if the string cannot be parsed |
| Array  | The length of the array |
| Other  | 1 if truthy, 0 if falsy |

| Parameters       | Return  | ひらがな Allowed? |
| ---------------- | ------- | ----------------- |
| `変数`: Anything | Integer | No                |

### String / Array Operations

#### `対象列に 要素を 押し込む`, `対象列に 要素を 追加する`

Pushes `要素` onto the end (highest index) of `対象列`. If `対象列` is a string: `要素` must be a string.

`追加する` is an alias of `押し込む`.

This modifies `対象列`.

| Parameters                                    | Return   | ひらがな Allowed? |
| --------------------------------------------- | -------- | ----------------- |
| `対象列`: Array or String<br>`要素`: Anything | `対象列` | Only `おしこむ`   |

#### `対象列から 引き出す`

Pops the last (highest index) element from `対象列`.

This modifies `対象列`.

| Parameters                | Return             | ひらがな Allowed?        |
| ------------------------- | ------------------ | ------------------------ |
| `対象列`: Array or String | The popped element | `引きだす` or `ひきだす` |

#### `対象列に 要素を 先頭から押し込む`

Pushes `要素` onto the beginning (0th index) of `対象列`. If `対象列` is a string: `要素` must be a string.

This modifies `対象列`.

| Parameters                                    | Return   | ひらがな Allowed?       |
| --------------------------------------------- | -------- | ----------------------- |
| `対象列`: Array or String<br>`要素`: Anything | `対象列` | Only `先頭からおしこむ` |

#### `対象列から 先頭を引き出す`

Pops the first element (0th index) of `対象列`.

This modifies `対象列`.

| Parameters                 | Return             | ひらがな Allowed?                    |
| -------------------------- | ------------------ | ------------------------------------ |
| `対象列`: Array or String  | The popped element | `先頭を引きだす` or `先頭をひきだす` |

#### `対象列から 要素を 抜く`, `対象列から 要素を 取る`

Removes the first `要素` from `対象列`.

`取る` is an alias of `抜く`.

This modifies `対象列`.

| Parameters                                    | Return              | ひらがな Allowed? |
| --------------------------------------------- | ------------------- | ----------------- |
| `対象列`: Array or String<br>`要素`: Anything | The removed element | Yes               |

#### `対象列から 要素を 全部抜く`, `対象列から 要素を 全部取る`

Removes all `要素` from `対象列`.

`全部取る` is an alias of `全部抜く`.

This modifies `対象列`.

| Parameters                                    | Return               | ひらがな Allowed?        |
| --------------------------------------------- | -------------------- | ------------------------ |
| `対象列`: Array or String<br>`要素`: Anything | The removed elements | `全部ぬく` or `全部とる` |

#### `対象列に 要素列を 繋ぐ`, `対象列に 要素列を 結合する`

Concatenates `要素列` to the end of `対象列`. `要素列` and `対象列` must be the same type.

`結合する` is an alias of `繋ぐ`. For more detail on how array keys interact, see the section on [Associative Arrays](#associative-arrays-aka-hashes-dictionaries).

| Parameters                                             | Return                        | ひらがな Allowed? |
| ------------------------------------------------------ | ----------------------------- | ----------------- |
| `対象列`: Array or String<br>`要素列`: Array or String | `対象列` joined with `要素列` | Only `つなぐ`     |

#### `要素列を ノリで 連結する`

Joins the elements of `要素列` using the delimiter `ノリ`. The elements of `要素列` will be formatted into strings.

| Parameters                        | Return   | ひらがな Allowed? |
| --------------------------------- | -------- | ----------------- |
| `要素列`: Array<br>`ノリ`: String | String   | No                |

#### `対象列を 区切りで 分割する`

Splits `対象列` by the delimiter `区切り`.

If `対象列` is an array: returns an array of arrays.

If `対象列` is a string: returns an array of strings. `区切り` must be a string.

| Parameters                                      | Return          | ひらがな Allowed? |
| ----------------------------------------------- | --------------- | ----------------- |
| `対象列`: Array or String<br>`区切り`: Anything | Array or String | No                |

#### `対象列を 始点から 終点まで 切り抜く`

Slices and removes a portion of `対象列` starting from `始点` until `終点`, inclusive.

Associative arrays are sliced using insertion order, ignoring keys.

`始点` and `終点` may exceed the boundaries, but will be treated as the first and last indices. Returns an empty array or string if `始点` is larger than `終点`.

This modifies `対象列`.

| Parameters                                                    | Return                               | ひらがな Allowed?    |
| ------------------------------------------------------------- | ------------------------------------ | -------------------- |
| `対象列`: Array or String<br>`始点`: Number<br>`終点`: Number | The removed slice of Array or String | 切りぬく or きりぬく |

#### `対象列で 要素を 探す`

Returns the corresponding key or index of the first instance of `要素` if found within `対象列`. Returns `無` if not found.

| Parameters                                    | Return           | ひらがな Allowed? |
| --------------------------------------------- | ---------------- | ----------------- |
| `対象列`: Array or String<br>`要素`: Anything | String or Number | Yes               |

#### `要素列を 並び順で 並び替える`

Returns `要素列` sorted by `並び順`.

`並び順` must be a string of either `昇順` or `降順`.

Each value's associated key will be retained in the new order.

If the array contains values of different types, they will be compared as strings. See [String Interpolation](#String-Interpolation) for more information on how values are stringified.

| Parameters      | Return          | ひらがな Allowed?   |
| --------------- | --------------- | ------------------- |
| `要素列`: Array | `要素列` sorted | Only `ならびかえる` |

### Math

#### `被加数に 加数を 足す`, `加数を 足す`

Adds `加数` to `被加数`. If `被加数` is omitted: adds `加数` to `それ`.

| Parameters                         | Return                         | ひらがな Allowed? |
| ---------------------------------- | ------------------------------ | ----------------- |
| `被加数`: Number<br>`加数`: Number | The sum of `加数` and `被加数` | Yes               |

#### `被減数から 減数を 引く`, `減数を 引く`

Subtracts `減数` from `被減数`. If `被減数` is omitted: Subtracts `減数` from `それ`.

| Parameters                         | Return                                | ひらがな Allowed? |
| ---------------------------------- | ------------------------------------- | ----------------- |
| `被減数`: Number<br>`減数`: Number | The difference of `減数` and `被減数` | Yes               |

#### `被乗数に 乗数を 掛ける`, `乗数を 掛ける`

Multiplies `被乗数` by `乗数`. If `被乗数` is omitted: Multiplies `それ` by `乗数`.

| Parameters                          | Return                             | ひらがな Allowed? |
| ----------------------------------- | ---------------------------------- | ----------------- |
| `被乗数`: Number<br>`乗数`: Number  | The product of `被乗数` and `乗数` | Yes               |

#### `被除数を 除数で 割る`, `除数で 割る`

Divides `被除数` by `除数`. If `被除数` is omitted: Divides `それ` by `除数`.

| Parameters                          | Return                              | ひらがな Allowed? |
| ----------------------------------- | ----------------------------------- | ----------------- |
| `被除数`: Number<br>`除数`: Number  | The dividend of `被除数` and `除数` | Yes               |

#### `被除数を 除数で 割った余りを求める`, `除数で 割った余りを求める`

Finds the remainder of `被除数` when divided by `除数`. If `被除数` is omitted: Finds the remainder of `それ` when divided by `除数`.

| Parameters                          | Return                                           | ひらがな Allowed? |
| ----------------------------------- | ------------------------------------------------ | ----------------- |
| `被除数`: Number<br>`除数`: Number  | The remainder of `被除数` when divided by `除数` | `わった余りを求める`,<br>`わったあまりを求める`,<br>or `わったあまりをもとめる` |

### Miscellaneous

#### `エラーを 投げる`

Prints `エラー` to stderr and throws an exception. Appending a bang will have no effect, unless the parameter itself is invalid in which case no error will be thrown. See the section on "[Exclamation Mark / Bangs](#Exclamation-Mark--Bangs)" for more detail.

| Parameters       | Return    | ひらがな Allowed? |
| ---------------- | --------- | ----------------- |
| `エラー`: String | Undefined | Yes               |

#### `値を 乱数の種に与える`

Sets the random seed.

| Parameters   | Return   | ひらがな Allowed?         |
| ------------ | -------- | ------------------------- |
| `種`: Number | Null     | Only `乱数の種にあたえる` |

#### `最低値から 最大値まで の乱数を発生させる`

Returns a non-cryptographically-secure random number between `最低値` and `最大値`, inclusive. `最低値` and `最大値` will be cast to integers.

| Parameters                           | Return | ひらがな Allowed? |
| ------------------------------------ | ------ | ----------------- |
| `最低値`: Number<br>`最大値`: Number | Number | No                |