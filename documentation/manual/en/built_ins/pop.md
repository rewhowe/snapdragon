[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Pop

## `対象列から 引き出す`

Pops the last (highest index) element from `対象列`.

This modifies `対象列`.

| Parameters                | Return             | ひらがな Allowed?        |
| ------------------------- | ------------------ | ------------------------ |
| `対象列`: Array or String | The popped element | `引きだす` or `ひきだす` |

Example:

```
ホゲは 「あ」、「い」、「う」 ※ {0: "あ", 1: "い", 2: "う"}

ホゲから 引き出す             ※ {0: "あ", 1: "い"}
それを 表示する               ※ "う"
```