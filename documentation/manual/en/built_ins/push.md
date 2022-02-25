[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Push

## `対象列に 要素を 押し込む`, `対象列に 要素を 追加する`

Pushes `要素` onto the end (highest index) of `対象列`. If `対象列` is a string: `要素` must be a string.

`追加する` is an alias of `押し込む`.

This modifies `対象列`.

| Parameters                                    | Return   | ひらがな Allowed? |
| --------------------------------------------- | -------- | ----------------- |
| `対象列`: Array or String<br>`要素`: Anything | `対象列` | Only `おしこむ`   |

Example:

```
ホゲは 「あ」、「い」、「う」 ※ {0: "あ", 1: "い", 2: "う"}

ホゲに 「え」を 押し込む      ※ {0: "あ", 1: "い", 2: "う", 3: "え"}
ホゲに 「お」を 追加する      ※ {0: "あ", 1: "い", 2: "う", 3: "え", 4: "お"}
```