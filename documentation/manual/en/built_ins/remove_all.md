[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Remove All

## `対象列から 要素を 全部抜く`, `対象列から 要素を 全部取る`

Removes all `要素` from `対象列`.

`全部取る` is an alias of `全部抜く`.

This modifies `対象列`.

| Parameters                                    | Return               | ひらがな Allowed?        |
| --------------------------------------------- | -------------------- | ------------------------ |
| `対象列`: Array or String<br>`要素`: Anything | The removed elements | `全部ぬく` or `全部とる` |

Example:

```
ホゲは 「あ」、「い」、「う」、「あ」 ※ {0: "あ", 1: "い", 2: "う", 3: "あ"}

ホゲから 「あ」を 全部抜く            ※ {1: "い", 2: "う"}
(「取る」も同様)
```