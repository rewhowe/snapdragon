[日本語](./manual_jp.md)

# Variables

Variables are declared using the following format: `[variable name]は [value]`.

Example:

```
ホゲは 1
```

This creates a variable `ホゲ` with the value `1`.

## Primitives / "Values"

Variables must be declared with initial values. Values can also be used directly as parameters to function calls.

### Numbers

A number follows the format `/-?(\d+\.\d+|\d+)/` (ie. negatives and floating points allowed).

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

#### String Length

A string's length may be found using the format: `[string|variable]の [length attribute]`.

Valid length attributes are: `長さ`, `大きさ`, or `数`, any of which may be written in ひらがな.

```
男子達は 「チャールス」、「ウイ」
女子達は 「ニッキー」、「セフ」

男性の人数は 男子達の 数

男性の人数に 女子達の 数を 足す
```

#### String Interpolation

(Planned for v1.1.0)

```
名前は 「世界」
「こんにちは【名前】！」を 言う
```

### Arrays

An array is a list of values delimited by commas (full-width `、` or half-width `,`).

Example:

```
ホゲは 1、2、3
フガは 1,2,3
ピヨは 「あ」、「い」、「う」、1、2、3
```

You can also declare an empty array with the keyword `配列`.

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

Like multi-line strings, spacing is not important, but you can realign items using a block comment if you want consistent indentation.

```
参加者は ※
※「ウイ」、
　「チャールス」、
　「ジャック＆
　　アジューラ」
```

#### Array Length

Array length can be found in the same way as string length. See the section on "String Length" for details.

### Associative Arrays (aka Hashes, Dictionaries)

(Planned for v1.1.0)

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

# Functions

## Defining Functions

Functions are declared using the following format: `[optional parameters] [function name]とは`.

Function names must be verbs (or verb phrases) and cannot be redeclared※ within the same scope (this includes collisions with built-in function names). Function bodies must be indented one whitespace character (full-width or half-width space, or tab; see the section on "Indentation" for more detail). Functions may not be defined within loops.

Parameters are each suffixed with one of the following particles: `から`, `で`, `と`, `に`, `へ`, `まで`, `を`. The particles are not part of the parameter names.

Example:

```
友達と 食べ物を 道具で 食べるとは
　・・・
```

This function, "食べる" takes three parameters: "友達", "食べ物", and "道具".

※ The particles used to define the function become part of its signature. A function with the same name can be redeclared as long as its signature is different (overloading), with the exception of built-ins and special keywords.

### Returning

There are multiple ways to return with differences in both semantics and functionality.

You can return a value using the following formats: `[返り値]を 返す` or `[返り値]と なる`. The former, "返す", can be used without a parameter and will implicitly return `それ`. The latter must have a parameter.

You can return without specifying a value using the following formats: `返る` or `戻る`. These differ in only semantics.

In the case of `返る`, `戻る`, or when a function has no return, the actual return value will be null.

Any of these keywords may be written in ひらがな.

## Calling functions

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

As mentioned in the section on "Variables", a function's return value will be available via the global variable `それ`.

Functions which throw an error will naturally return null (see the section on "Punctuation" for allowing error-throwing).

## Conjugations

When a function is defined, its た-form (aka "perfective", "past tense") and て-form (aka "participle", "command") conjugations also become available. Verbs ending with いる and える are difficult to distinguish between 五段動詞 and 一段動詞 so both conjugations are available (just in case!).

Example:

```
食べ物を 食べるとは
　・・・

「ふわふわ卵のヒレカツ丼」を 食べた
「もうひとつのヒレカツ丼」を 食べて
「まだまだヒレカツ丼」を 食べって (Incorrect but usable
```

Some verbs may end up having ambiguous conjugations. In this case, an error will be thrown during parsing. You may append an exclamation mark (full-width `！` or half-width `!`) to the function definition to allow subsequent functions to overwrite the conjugations of previously-defined functions. The base form of the previously-defined functions will still be usable.

```
商品を かうとは
　・・・

草を かるとは (This will throw an error during parsing
　・・・

草を かるとは！ (No error - overrides conjugations of かう
　・・・

「芝生」を かう   (かう is still callable
「芝生」を かって (Refers to かる instead of かう
```

By doing this, it is possible to overwrite the conjugated forms of built-in functions, although this is not recommended.

----

# Control Structures

## Conditional Branching

A conditional branch follows the format: `もし [conditional statement]`. The body must be indented one whitespace character (full-width or half-width space or tab; see the section on "Indentation" for more detail).

The conditional statement is generally comprised of three parts: comparator 1, comparator 2, and comparator 3 (creative, I know).

Comparator 1 follows the format: `[variable or value]が`. This variable or value is the first operand.

Comparator 2 is a variable or value (the second operand) followed by one of `と`, `より`, `以上`, `以下`, question mark (full-width or half-width).

Comparator 3 is one of `ならば`, `でなければ`, `等しければ`, `大きければ`, `小さければ`.

Comparator 2 and comparator 3, together, form the logical operator, and follow the format: `[variable or value][comparator 2] [comparator 3]`. Comparator 2 using a question mark (full-width `？` or half-width `?`) is equivalent to a normal `==` comparison. The associated comparator 3 is `ならば`. Conversely, if comparator 3 is `でなければ`, the comparison is reversed to `!=`.

Below is a chart of various comparisons between two variables, `Ａ` and `Ｂ`:

| Comparison                         | Logical Operation |
| ---------------------------------- | ----------------- |
| もし　Ａが　Ｂと　　等しければ     | `Ａ == Ｂ`        |
| もし　Ａが　Ｂより　大きければ     | `Ａ > Ｂ`         |
| もし　Ａが　Ｂより　小さければ     | `Ａ < Ｂ`         |
| もし　Ａが　Ｂ以上　ならば         | `Ａ >= Ｂ`        |
| もし　Ａが　Ｂ以下　ならば         | `Ａ <= Ｂ`        |
| もし　Ａが　Ｂと　　等しくなければ | `Ａ != Ｂ`        |
| もし　Ａが　Ｂ？　　ならば         | `Ａ == Ｂ`        |
| もし　Ａが　Ｂ？　　でなければ     | `Ａ != Ｂ`        |
| もし　Ａ？　ならば                 | `Ａ`              |
| もし　Ａ？　でなければ             | `!Ａ`             |

Comparator 3 can be written in plain ひらがな as well (without kanji).

Example:

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

### ELSE IF and ELSE

Following an if-statement, an else-if or an else-statement can be added at the same indentation level as the initial if-statement.

The else-if statement follows the format: `もしくは [conditional statement]` or `または [conditional statement]` where the conditional statement is as described in the previous section. Multiple else-ifs are allowed.

The else statement is a single keyword, either `それ以外` or `違えば` (but only the latter may be written in ひらがな).

```
もし Ａが Ｂと 等しければ
　・・・
もしくは Ａが Ｂより 大きければ
　・・・
または Ａが Ｂより 小さければ
　・・・
それ以外
　・・・
```

### Function Calls As Conditions

In addition to the three-part conditional statement, function calls suffixed by a question mark (full-width `？` or half-width `?`) and `ならば` can also be used as conditions.

Example:

```
もし 「ふわふわ卵のヒレカツ丼」を 食べた？ ならば
　・・・
```

To reverse the condition, use `でなければ`.

### Multiple-Condition Branching

(Planned for v1.1.0)

## Looping

The looping keyword is `繰り返す`. This can be written with any combination of kanji or ひらがな.

There are two ways to perform looping: with (optional) start and end parameters, or over a container object.

A loop can be immediately exited using the keyword `終わり` or an iteration can be skipped with `次`. Both can be written in ひらがな.

Loop bodies must be indented one whitespace character (full-width or half-width space, or tab; see the section on "Indentation" for more detail).

### With Parameters

A simple loop must either use two parameters (start and end) or no parameters (an infinite loop unless manually broken). It follows the format `[optional parameters] 繰り返す`.

If using two parameters, they must be either variables or numeric primitives. Note that variables should be numeric, but there is no safety check for this. The parameters must also use the particles から and まで to specify start and end, respectively, however the order does not matter.

Example:

```
1から 100まで 繰り返す
　・・・

繰り返す
　「無限ループ？」を 言う
　終わり
```

### Over An Object

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

----

# Try-Catch

(Planned for v1.1.0)

----

# Misc

## Indentation

Indentation is determined by the number of whitespace characters. The main body of the script must not be indented, and each subsequent body of functions, if-statements, or loops must be indented one level deeper than its parent. However the type of indentation may be full-width or half-width spaces or tabs, or a mixture (for those who enjoy illegible spaghetti).

Full-width spaces may be preferred as it makes indentation easy with a Japanese input method editor enabled, however tabs are recommended. Tabs have the benefit of being single byte characters while also having their display width freely configurable for each developer's preference.

## Exit

You can exit a script only from the main scope. The keyword and functionality is the same as returning. See the section on "Returning" for details.

## No-op

Like Python's `pass`, Snapdragon provides `・・・` as a no-op. You can use it to stub functions for later implementation, or to signify an intentionally-empty block.

## Comments

Plain inline comments are prefixed with `(` or `（`, like an "aside".

Block comments are encompassed by the `※` character.

Example:

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

## Punctuation

### Exclamation Mark / Bangs

Functions, by default, will return null on error. Suffixing a function call with an exclamation mark (full-width `！` or half-width `!`) will allow errors to be thrown (see the section on "Try-Catch" for handling).

Example:

```
食べ物を 食べるとは
　・・・

「プラスチック」を 食べる　（エラー無し
「プラスチック」を 食べる！（エラー有り
```

### Question Mark

A variable or function call suffixed with a question mark (full-width `？` or half-width `?`) will have its value or return value cast to a boolean (see the section on "Conditional Branching" for use within conditional statements).

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
(Result: false, true, false, false, true, false
```

It is important to remember that this use of question mark is a boolean cast and not a calculation of equality like it is in if-statements.

```
ホゲは 1
ホゲは 2？ (ホゲ is true - it is not a comparison of 1 and 2, but a boolean cast of 2
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

## Debugging

Like the "[original bug](https://en.wikipedia.org/wiki/Software_bug#History)", you can use the command `蛾` to dump the entire program state (up until that point). Followed by a bang (full-width `！` or half-width `!`), this will cause execution to stop.

To print a single variable or value as-is, use the built-in function `データを ポイ捨てる`. Followed by a bang, this will cause execution to stop.

These commands are only executed if the command line option for debugging is enabled.

----

# Built-in Functions

## `言葉と 言う`, `言葉を 言う`

Prints `言葉` to stdout. `言葉を 言う` differs in semantics only.

| Parameters     | Return | ひらがな Allowed? |
| -------------- | ------ | ----------------- |
| `言葉`: String | `言葉` | Yes               |

## `メッセージを 表示する`

Prints `メッセージ` to stdout. A newline will be appended.

| Parameters             | Return       | ひらがな Allowed? |
| ---------------------- | ------------ | ----------------- |
| `メッセージ`: Anything | `メッセージ` | No                |

## `データを ポイ捨てる`

Dumps `データ` to stdout if debugging is enabled. Causes execution to stop if followed by a bang (full-width `！` or half-width `!`).

| Parameters         | Return   | ひらがな Allowed? |
| ------------------ | -------- | ----------------- |
| `データ`: Anything | `データ` | No                |

## `エラーを 投げる`

Prints `エラー` to stderr and throws an exception. When a bang is appended, the error will only be suppressed if the parameter is invalid.

| Parameters       | Return    | ひらがな Allowed? |
| ---------------- | --------- | ----------------- |
| `エラー`: String | Undefined | Yes               |

## `対象列に 要素を 追加する`

If `対象列` is an array: appends `要素`. If `対象列` is a string: concatenates `要素`; `要素` must be a string.

| Parameters                                     | Return   | ひらがな Allowed? |
| ---------------------------------------------- | -------- | ----------------- |
| `対象列`: Array or String<br>`要素`: Anything  | `対象列` | No                |

## `対象列に 要素列を 連結する`

Concatenates `要素列` to the end of `対象列`. `要素列` and `対象列` must be the same type.

| Parameters                                             | Return   | ひらがな Allowed? |
| ------------------------------------------------------ | -------- | ----------------- |
| `対象列`: Array or String<br>`要素列`: Array or String | `対象列` | No                |

## `対象列から 要素を 抜く`

Removes the first `要素` from `対象列`.

This modifies `対象列`.

| Parameters                                    | Return              | ひらがな Allowed? |
| --------------------------------------------- | ------------------- | ----------------- |
| `要素`: Anything<br>`対象列`: Array or String | The removed element | Yes               |

## `対象列から 要素を 全部抜く`

Removes all `要素` from `対象列`.

This modifies `対象列`.

| Parameters                                    | Return               | ひらがな Allowed? |
| --------------------------------------------- | -------------------- | ----------------- |
| `要素`: Anything<br>`対象列`: Array or String | The removed elements | Only `全部ぬく`   |

## `対象列に 要素を 押し込む`

Pushes `要素` onto the end (highest index) of `対象列`. If `対象列` is a string: `要素` must be a string.

This modifies `対象列`.

| Parameters                                    | Return   | ひらがな Allowed? |
| --------------------------------------------- | -------- | ----------------- |
| `要素`: Anything<br>`対象列`: Array or String | `対象列` | Only `おしこむ`   |

## `対象列から 抜き出す`

Pops the last (highest index) element from `対象列`.

This modifies `対象列`.

| Parameters                | Return             | ひらがな Allowed?        |
| ------------------------- | ------------------ | ------------------------ |
| `対象列`: Array or String | The popped element | `抜きだす` or `ぬきだす` |

## `対象列に 要素を 先頭から押し込む`

Pushes `要素` onto the beginning (0th index) of `対象列`. If `対象列` is a string: `要素` must be a string.

This modifies `対象列`.

| Parameters                                    | Return   | ひらがな Allowed?       |
| --------------------------------------------- | -------- | ----------------------- |
| `対象列`: Array or String<br>`要素`: Anything | `対象列` | Only `先頭からおしこむ` |

## `対象列から 先頭を抜き出す`

Pops the first element (0th index) of `対象列`.

This modifies `対象列`.

| Parameters                 | Return             | ひらがな Allowed?                    |
| -------------------------- | ------------------ | ------------------------------------ |
| `対象列`: Array or String  | The popped element | `先頭を抜きだす` or `先頭をぬきだす` |

## `被加数に 加数を 足す`, `加数を 足す`

Adds `加数` to `被加数`. If `被加数` is omitted: adds `加数` to `それ`.

| Parameters                         | Return                         | ひらがな Allowed? |
| ---------------------------------- | ------------------------------ | ----------------- |
| `加数`: Number<br>`被加数`: Number | The sum of `加数` and `被加数` | Yes               |

## `被減数から 減数を 引く`, `減数を 引く`

Subtracts `減数` from `被減数`. If `被減数` is omitted: Subtracts `減数` from `それ`.

| Parameters                         | Return                                | ひらがな Allowed? |
| ---------------------------------- | ------------------------------------- | ----------------- |
| `減数`: Number<br>`被減数`: Number | The difference of `減数` and `被減数` | Yes               |

## `被乗数に 乗数を 掛ける`, `乗数を 掛ける`

Multiplies `被乗数` by `乗数`. If `被乗数` is omitted: Multiplies `それ` by `乗数`.

| Parameters                          | Return                             | ひらがな Allowed? |
| ----------------------------------- | ---------------------------------- | ----------------- |
| `被乗数`: Number<br>`乗数`: Number  | The product of `被乗数` and `乗数` | Yes               |

## `被除数を 除数で 割る`, `除数で 割る`

Divides `被除数` by `除数`. If `被除数` is omitted: Divides `それ` by `除数`.

| Parameters                          | Return                               | ひらがな Allowed? |
| ----------------------------------- | ------------------------------------ | ----------------- |
| `被除数`: Number<br>`除数`: Number  | The dividend of `被除数` and `除数` | Yes               |

## `被除数を 除数で 割った余りを求める`, `除数で 割った余りを求める`

Finds the remainder of `被除数` when divided by `除数`. If `被除数` is omitted: Finds the remainder of `それ` when divided by `除数`.

| Parameters                          | Return                                         | ひらがな Allowed? |
| ----------------------------------- | ---------------------------------------------- | ----------------- |
| `被除数`: Number<br>`除数`: Number  | The remainder of `被除数` when divided by `除数` | `わった余りを求める`,<br>`わったあまりを求める`,<br>or `わったあまりをもとめる` |