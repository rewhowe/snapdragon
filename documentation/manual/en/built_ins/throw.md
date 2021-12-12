[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Throw

## `エラーを 投げる`

Prints `エラー` to stderr and throws an exception. Appending a bang will have no effect, unless the parameter itself is invalid in which case no error will be thrown. See the section on "[Exclamation Mark / Bangs](#Exclamation-Mark--Bangs)" for more detail.

| Parameters       | Return    | ひらがな Allowed? |
| ---------------- | --------- | ----------------- |
| `エラー`: String | Undefined | Yes               |

Example:

```
「ご飯がない！」を 投げる
```