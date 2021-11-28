[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Cast To Integer

## `変数を 整数化する`

Converts `変数` into its integer equivalent according to the following logic:

| Type   | Returns |
| ------ | ------- |
| Number | The number with its fractional portion removed |
| String | The string parsed as an integer; Throws an error if the string cannot be parsed |
| Array  | The length of the array |
| Other  | 1 if truthy, 0 if falsy |

| Parameters       | Return  | ひらがな Allowed? |
| ---------------- | ------- | ----------------- |
| `変数`: Anything | Integer | No                |

Example:

```
「4649.4649」を 整数化する ※ 4649

ホゲは 「あ」、「い」、「う」
それを 整数化する ※ 3

真を 整数化する ※ 1
偽を 整数化する ※ 0
無を 整数化する ※ 0
```