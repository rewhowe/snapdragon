[Manual](../../en.md) > [Built-Ins](../built_ins.md) > Dump

## `データを ポイ捨てる`

Dumps `データ` to stdout if debugging is enabled. Causes execution to stop if followed by a bang (full-width `！` or half-width `!`).

| Parameters         | Return   | ひらがな Allowed? |
| ------------------ | -------- | ----------------- |
| `データ`: Anything | `データ` | No                |

Example:

```
ホゲは 配列
ホゲの 「フガ」は 「ピヨ」
ホゲを ポイ捨てる         ※ {"フガ": "ピヨ"} (only in debug mode)
```