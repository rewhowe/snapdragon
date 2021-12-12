[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Join

## `要素列を ノリで 連結する`

Joins the elements of `要素列` using the delimiter `ノリ`. The elements of `要素列` will be formatted into strings.

| Parameters                        | Return   | ひらがな Allowed? |
| --------------------------------- | -------- | ----------------- |
| `要素列`: Array<br>`ノリ`: String | String   | No                |

Example:

```
ホゲは 「あ」、「い」、「う」 ※ {0: "あ", 1: "い", 2: "う"}

ホゲを 「、」で 連結する      ※ あ、い、う
```