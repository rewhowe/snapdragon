[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Sort

## `要素列を 並び順で 並び替える`

Returns `要素列` sorted by `並び順`.

`並び順` must be a string of either `昇順` or `降順`.

Each value's associated key will be retained in the new order.

If the array contains values of different types, they will be compared as strings. See [String Interpolation](#String-Interpolation) for more information on how values are stringified.

| Parameters      | Return          | ひらがな Allowed?   |
| --------------- | --------------- | ------------------- |
| `要素列`: Array | `要素列` sorted | Only `ならびかえる` |

Example:

```
ホゲは 「あ」、「い」、「う」、「え」、「お」

ホゲを 「昇順」で 並び替える ※ {0: "あ", 1: "い", 2: "う", 3: "え", 4: "お"}
ホゲを 「降順」で 並び替える ※ {4: "お", 3: "え", 2: "う", 1: "い", 0: "あ"}
```