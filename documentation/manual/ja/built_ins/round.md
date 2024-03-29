[資料集・マニュアル](../../ja.md) > [ビルトイン関数（組み込み関数）](../built_ins.md) > 切り上げる、切り下げる、切り捨てる

## `数値を 精度に 切り上げる`, `数値を 精度に 切り下げる`, `数値を 精度に 切り捨てる`

この3つの関数はそれぞれ、処理が少し異なる。

* `切り上げる` - `数値`を自身以上の最も近い`N`桁に四捨五入する。
* `切り下げる` - `数値`を自身以下の最も近い`N`桁に四捨五入する。
* `切り捨てる` - `数値`を最も近い`N`桁に四捨五入する。（5以上は上がる、4以下は下がる。）

`精度`は次のようなフォーマットの文字列：

* `N桁`の場合：小数点の前の`N`桁に四捨五入する。
* `少数第N位`または`少数点第2位`の場合：諸数点の後の`N`桁に四捨五入する。

| 引数                           | 戻り値  | ひらがな可能                               |
| ------------------------------ | ------- | ------------------------------------------ |
| `数値`: 数値<br>`精度`: 文字列 | 数値    | `きりあげる`,`きりさげる`, or `きりすてる` |

例）

```
4649.4649を 「1桁」に 切り上げる ※ 4650
4649.4649を 「2桁」に 切り上げる ※ 4650
4649.4649を 「3桁」に 切り上げる ※ 4700

4649.4649を 「小数第1位」に 切り上げる ※ 4649.5
4649.4649を 「小数第2位」に 切り上げる ※ 4649.47
4649.4649を 「小数第3位」に 切り上げる ※ 4649.465

4649.4649を 「1桁」に 切り下げる ※ 4649
4649.4649を 「2桁」に 切り下げる ※ 4640
4649.4649を 「3桁」に 切り下げる ※ 4600

4649.4649を 「小数第1位」に 切り下げる ※ 4649.4
4649.4649を 「小数第2位」に 切り下げる ※ 4649.46
4649.4649を 「小数第3位」に 切り下げる ※ 4649.464

4649.4649を 「1桁」に 切り捨てる ※ 4649
4649.4649を 「2桁」に 切り捨てる ※ 4650
4649.4649を 「3桁」に 切り捨てる ※ 4600

4649.4649を 「小数第1位」に 切り捨てる ※ 4649.5
4649.4649を 「小数第2位」に 切り捨てる ※ 4649.46
4649.4649を 「小数第3位」に 切り捨てる ※ 4649.465
```
