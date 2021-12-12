[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Format

## `フォーマット文に 引数を 記入する`

Formats an array or variable `引数` into placeholders, signified by `〇`, within `フォーマット文`. Literal 〇 may be escaped by prepending them with a backslash `\`.

The number of placeholders must equal the number array elements of `引数`, or exactly 1 if `引数` is not an array.

Numeric parameters may be formatted by following `〇` with a parenthesized format string `A詰めB桁。C詰めD桁` (decimal may be full-width or half-width). The formatted string will be `A`-padded `B`-digits before the decimal and `C`-padded `D`-digits after the decimal. `A`, `C`, and `D` default to `0` if omitted. If `D` is `0`, the decimal will be removed. Digits before the decimal will not be truncated if longer than `B`.

A literal parenthesis following `〇` may be escaped by prepending it with a backslash `\`.

| Parameters                                   | Return               | ひらがな Allowed? |
| -------------------------------------------- | -------------------- | ----------------- |
| `フォーマット文`: String<br>`引数`: Anything | The formatted string | No                |

Example:

```
「こんにちは、〇！お元気ですか？」に 「リュウ」を 記入する ※ 「こんにちは、リュウ！お元気ですか？」

「〇（　詰め4桁.6桁）」に 49を 記入する                    ※ 「　　　4.900000」

スリーサイズは 36, 24, 36, 5.30
「〇, 〇, 〇? Haha, only if she's 〇(1桁.1桁)！」に スリーサイズを 記入する
```