[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Split

## `対象列を 区切りで 分割する`

Splits `対象列` by the delimiter `区切り`.

If `対象列` is an array: returns an array of arrays.

If `対象列` is a string: returns an array of strings. `区切り` must be a string.

| Parameters                                      | Return          | ひらがな Allowed? |
| ----------------------------------------------- | --------------- | ----------------- |
| `対象列`: Array or String<br>`区切り`: Anything | Array or String | No                |

Example:

```
「あ、い、う」を 「、」で 分割する ※ {0: "あ", 1: "い", 2: "う"}
```