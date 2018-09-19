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

A string is encompassed in the characters `「` (start) and `」` (end).

Example:

```
ホゲは 「もじれつ」
```

You can escape the closing character by prefixing it with a backslash.

Example:

```
ホゲは 「文字列の中の「もじれつ\」」
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

### Booleans

| Boolean | Supported Keywords         |
| ------- | -------------------------- |
| True    | `真`, `肯定`, `はい`, `正` |
| False   | `偽`, `否定`, `いいえ`     |

### それ / あれ

Like なでしこ, `それ` is a special global variable equal to the value of the last-executed statement.

Similarly, `あれ` is another special global variable. Use it as you like!

----

# Functions

## Defining Functions

Functions are declared using the following format: `[optional parameters] [function name]とは`.

Function names must be verbs (or verb phrases) and cannot be redeclared within the same scope (this includes collisions with built-in function names).

Parameters (TODO)

supported particles, particle order, etc

# Calling functions

conjugations

# Conditional Branching

TODO

## Single-Condition Branch

TODO

# Misc

## No-op

Like Python's `pass`, Snapdragon provies `・・・` as a no-op. You can use it to stub functions for later implementation, or to signify an intentionally-empty block.

## Comments

TODO

## Punctuation

# Built-in Functions

TODO
