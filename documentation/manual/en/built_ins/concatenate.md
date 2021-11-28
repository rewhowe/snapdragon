[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Concatenate

## `対象列に 要素列を 繋ぐ`, `対象列に 要素列を 結合する`

Concatenates `要素列` to the end of `対象列`. `要素列` and `対象列` must be the same type.

`結合する` is an alias of `繋ぐ`. For more detail on how array keys interact, see the section on [Associative Arrays](#associative-arrays-aka-hashes-dictionaries).

| Parameters                                             | Return                        | ひらがな Allowed? |
| ------------------------------------------------------ | ----------------------------- | ----------------- |
| `対象列`: Array or String<br>`要素列`: Array or String | `対象列` joined with `要素列` | Only `つなぐ`     |

Example:

```
ホゲは 「あ」、「い」、「う」 ※ {0: "あ", 1: "い", 2: "う"}
フガは 「え」、「お」         ※ {0: "え", 1: "お"}

ホゲに フガを 繋ぐ            ※ {0: "あ", 1: "い", 2: "う", 3: "え", 4: "お"}
(「結合する」も同様)
```