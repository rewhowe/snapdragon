[資料集・マニュアル](../../ja.md) > [ビルトイン関数（組み込み関数）](../built_ins.md) > 連結する

## `要素列を ノリで 連結する`

`要素列`の要素をそれぞれ文字列化して、`ノリ`の区切りで繋ぐ。

| 引数                             | 戻り値   | ひらがな可能 |
| -------------------------------- | -------- | ------------ |
| `要素列`: 配列<br>`ノリ`: 文字列 | 文字列   | ☓           |

例）

```
ホゲは 「あ」、「い」、「う」 ※ {0: "あ", 1: "い", 2: "う"}

ホゲを 「、」で 連結する      ※ あ、い、う
```