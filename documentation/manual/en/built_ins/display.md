[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Display

## `メッセージを 表示する`

Prints `メッセージ` to stdout. A newline will be appended.

| Parameters             | Return       | ひらがな Allowed? |
| ---------------------- | ------------ | ----------------- |
| `メッセージ`: Anything | `メッセージ` | No                |

Example:

```
「こんにちは、世界」を 表示する ※ "こんにちは、世界"

ホゲは 1
それを 表示する                 ※ 1

フガは 「あ」、「い」、「う」
それを 表示する                 ※ {0: "あ", 1: "い", 2: "う"}
```