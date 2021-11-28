[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Slice

## `対象列を 始点から 終点まで 切り抜く`

Slices and removes a portion of `対象列` starting from `始点` until `終点`, inclusive.

Associative arrays are sliced using insertion order, ignoring keys.

`始点` and `終点` may exceed the boundaries, but will be treated as the first and last indices. Returns an empty array or string if `始点` is larger than `終点`.

This modifies `対象列`.

| Parameters                                                    | Return                               | ひらがな Allowed?    |
| ------------------------------------------------------------- | ------------------------------------ | -------------------- |
| `対象列`: Array or String<br>`始点`: Number<br>`終点`: Number | The removed slice of Array or String | 切りぬく or きりぬく |

Example:

```
挨拶は 「こんにちは、世界」

挨拶を 6から 8まで 切り抜く ※ 世界
挨拶を 表示する             ※ こんにちは、
```