[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Cast To Numeric

## `変数を 数値化する`

Converts `変数` into its numeric equivalent according to following logic:

| Type   | Returns |
| ------ | ------- |
| Number | The number unchanged |
| String | The string parsed as a number; Throws an error if the string cannot be parsed |
| Array  | The length of the array |
| Other  | 1 if truthy, 0 if falsy |

| Parameters       | Return | ひらがな Allowed? |
| ---------------- | ------ | ----------------- |
| `変数`: Anything | Number | No                |

Example:

```
「4649.4649」を 数値化する ※ 4649.4649

ホゲは 「あ」、「い」、「う」
それを 数値化する ※ 3

真を 数値化する ※ 1
偽を 数値化する ※ 0
無を 数値化する ※ 0
```