[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Remove

## `対象列から 要素を 抜く`, `対象列から 要素を 取る`

Removes the first `要素` from `対象列`.

`取る` is an alias of `抜く`.

This modifies `対象列`.

| Parameters                                    | Return              | ひらがな Allowed? |
| --------------------------------------------- | ------------------- | ----------------- |
| `対象列`: Array or String<br>`要素`: Anything | The removed element | Yes               |

Example:

```
ホゲは 「あ」、「い」、「う」、「あ」 ※ {0: "あ", 1: "い", 2: "う", 3: "あ"}

ホゲから 「あ」を 抜く                ※ {1: "い", 2: "う", 3: "あ"}
ホゲから 「あ」を 取る                ※ {1: "い", 2: "う"}
```