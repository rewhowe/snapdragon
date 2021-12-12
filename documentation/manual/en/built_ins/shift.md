[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Shift

## `対象列から 先頭を引き出す`

Pops the first element (0th index) of `対象列`.

This modifies `対象列`.

| Parameters                 | Return             | ひらがな Allowed?                    |
| -------------------------- | ------------------ | ------------------------------------ |
| `対象列`: Array or String  | The popped element | `先頭を引きだす` or `先頭をひきだす` |

Example:

```
ホゲは 「あ」、「い」、「う」    ※ {0: "あ", 1: "い", 2: "う"}

ホゲから 先頭を引き出す ※ {0: "い", 1: "う"}
```