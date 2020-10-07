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

Strings may span multiple lines. Trailing and leading whitespace, including newlines, will be stripped. You can insert a newline using `\n` or `￥ｎ`.

```
作文は 「こんにちは。
         今日の予定は特になし。
         週末にカツ丼を食べに行く。」

「カツ丼が好き。￥ｎ
　毎日食べても飽きない。」を 言う
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

Function names must be verbs (or verb phrases) and cannot be redeclared※ within the same scope (this includes collisions with built-in function names). Function bodies must be indented one space (full-width or half-width). Functions may not be defined within loops.

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

----

# Control Structures

## Conditional Branching

A conditional branch follows the format: `もし [conditional statement]`. The body must be indented one space (full-width or half-width).

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

----

# Built-in Functions

| Function Signature                   | Purpose                                             |
| ------------------------------------ | --------------------------------------------------- |
| `言葉と 言う`                        | `printf` / `print` / `console.log` / etc            |
| `言葉を 言う`                        | " (differs in semantics only)                       |
| `メッセージを ログする`              | output to log / `console.log` / etc                 |
| `メッセージを 表示する`              | std out / `print` / `alert` / etc                   |
| `エラーを 投げる`                    | std err / `raise` / `alert` / etc (throws an error) |
| `要素を 対象列に 追加する`           | append to list; concatenate to string               |
| `要素列を 対象列に 連結する`         | concatenate lists; concatenate strings              |
| `対象列から 要素を 抜く`             | remove first 要素 from 対象列                       |
| `対象列から 要素を 全部抜く`         | remove all 要素 from 対象列                         |
| `対象列に 要素を 押し込む`           | push 要素 onto the end (highest index) of 対象列    |
| `対象列から 抜き出す`                | pop the last (highest index) element from 対象列    |
| `対象列に 要素を 先頭から押し込む`   | push 要素 onto the beginning (0th index) of 対象列  |
| `対象列から 先頭を抜き出す`          | pop the first element (0th index) of 対象列         |
| `被加数に 加数を 足す`               | add 加数 to 被加数                                  |
| `加数を 足す`                        | add 加数 to それ                                    |
| `被減数から 減数を 引く`             | subtract 減数 from 被減数                           |
| `減数を 引く`                        | subtract 減数 from それ                             |
| `被乗数に 乗数を 掛ける`             | multiply 乗数 with 被乗数                           |
| `乗数を 掛ける`                      | multiply 乗数 with それ                             |
| `被除数を 除数で 割る`               | divide 被除数 by 除数                               |
| `除数で 割る`                        | divide それ by 除数                                 |
| `被除数を 除数で 割った余りを求める` | find remainder of 被除数 divided by 除数            |
| `除数で 割った余りを求める`          | find remainder of それ divided by 除数              |

As you may expect, all of the above built-ins can be written in plain ひらがな.
