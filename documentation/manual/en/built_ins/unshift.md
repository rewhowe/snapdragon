[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Unshift

## `対象列に 要素を 先頭から押し込む`

Pushes `要素` onto the beginning (0th index) of `対象列`. If `対象列` is a string: `要素` must be a string.

This modifies `対象列`.

| Parameters                                    | Return   | ひらがな Allowed?       |
| --------------------------------------------- | -------- | ----------------------- |
| `対象列`: Array or String<br>`要素`: Anything | `対象列` | Only `先頭からおしこむ` |

Example:

```
ホゲは 「あ」、「い」、「う」    ※ {0: "あ", 1: "い", 2: "う"}

ホゲに 「え」を 先頭から押し込む ※ {0: "え", 1: "あ", 2: "い", 3: "う"}
```