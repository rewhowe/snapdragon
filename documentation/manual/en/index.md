[Manual](../en.md) > Index

## Index

* [Standard Keywords](#Standard-Keywords)
* [Particles](#Particles)
* [Special and Primitive Values](#Special-and-Primitive-Values)
* [Properties and Counters](#Properties-and-Counters)
* [Punctuation and Symbols](#Punctuation-and-Symbols)
* [Built-Ins](#Built-Ins)

### Standard Keywords

| Keyword    | Alternate Writing | Usage |
| ---------- | ----------------- | ----- |
| あり       |                   | Existence check end-if conjunctive form |
| ある       |                   | Existence check end-if attributive form |
| あれば     |                   | Existence check end-if |
| する       |                   | Do (currently only used in logarithms) |
| であり     | で                | Plain end-if conjunctive form |
| である     |                   | Plain end-if attributive form |
| でない     | じゃない<br>ない  | Negative end-if attributive form |
| でなく     | じゃなく<br>なく  | Negative end-if conjunctive form |
| でなければ | じゃなければ      | Negative end-if |
| でなければ | じゃなければ<br>それ以外ならば<br>それ以外なら<br>それ以外は<br>それ以外だと<br>違えば<br>ちがえば<br>違うならば<br>ちがうならば<br>違うなら<br>ちがうなら | Else |
| ない       |                   | Non-existence check end-if attributive form |
| なく       |                   | Non-existence check end-if conjunctive form |
| なければ   |                   | Non-existence check end-if |
| ならば     | なら<br>であれば  | Plain end-if |
| もし       |                   | If |
| もしくは   | または            | Else-if |
| 且つ       | かつ              | And conjunction |
| 中         | なか              | Inside check |
| 以上       |                   | Greater-than comparison |
| 以下       |                   | Less-than comparison |
| 低と       | ていと            | Denotes logarithm base |
| 偽の       |                   | Falsy check attributive form |
| 又は       | または            | Or conjunction |
| 同じ       | おなじ            | Equality comparison |
| 回         |                   | Static loop count |
| 大きい     | おおきい<br>長い<br>ながい<br>高い<br>たかい<br>多い<br>おおい | Greater-than end-if attributive form |
| 大きく     | おおきく<br>長く<br>ながく<br>高く<br>たかく<br>多く<br>おおく | Greater-than end-if conjunctive form |
| 大きければ | おおきければ<br>長ければ<br>ながければ<br>高ければ<br>たかければ<br>多ければ<br>おおければ | Greater-than end-if |
| 対して     | たいして          | Denotes loop iterator |
| 対数       | たいすう          | [Logarithm](./built_ins/logarithm.md) |
| 小さい     | ちいさい<br>短い<br>みじかい<br>低い<br>ひくい<br>少ない<br>すくない | Less-than end-if attributive form |
| 小さく     | ちいさく<br>短く<br>みじかく<br>低く<br>ひくく<br>少なく<br>すくなく | Less-than end-if conjunctive form |
| 小さければ | ちいさければ<br>短ければ<br>みじかければ<br>低ければ<br>ひくければ<br>少なければ<br>すくなければ | Less-than end-if |
| 次         | つぎ              | Next loop |
| 真の       |                   | Truthy check attributive form |
| 空         | から              | Empty check |
| 終わり     | おわり            | End loop (break) |
| 繰り返す   | 繰りかえす<br>くり返す<br>くりかえす | Loop |
| 蛾         |                   | Debug |
| 試す       | ためす            | Try |
| 返る       | かえる<br>返す<br>かえす<br>戻る<br>もどる<br>なる | Return |
| 限り       | かぎり            | Denotes while loop condition |

### Particles

| Particle                                   | Usage |
| ------------------------------------------ | ----- |
| から                                       | Loop starting index |
| から<br>で<br>と<br>に<br>へ<br>まで<br>を | Supported function particles |
| と                                         | Used in equals comparison |
| とは                                       | Function definition |
| の                                         | Possessive |
| は                                         | Variable definition / assignment |
| まで                                       | Loop ending index |
| より                                       | Used in less-than/greater-than comparison |

### Special and Primitive Values

| Keyword | Alternate Writing    | Usage |
| ------- | -------------------- | ----- |
| あれ    |                      | Free-use global |
| それ    |                      | Holds the last executed statement's value |
| 例外    |                      | Holds the last thrown error |
| 偽      | 否定<br>いいえ       | False |
| 引数列  |                      | Argument vector |
| 無      | 無い<br>無し<br>ヌル | Null |
| 真      | 肯定<br>はい<br>正   | True |
| 配列    | 連想配列             | Array |

### Properties and Counters

| Keyword  | Alternate Writing                          | Usage |
| -------- | ------------------------------------------ | ----- |
| あの乗   |                                            | Raise to power of あれ's value |
| あの乗根 |                                            | Calculate root with あれ's value |
| その乗   |                                            | Raise to power of それ's value |
| その乗根 |                                            | Calculate root with それ's value |
| つ<br>人<br>個<br>件<br>匹<br>文字 |                  | Supported counters |
| キー列   |                                            | Keys |
| 乗       |                                            | Following number N: Nth power |
| 乗根     |                                            | Following number N: Nth root |
| 先頭     |                                            | First element |
| 先頭以外 |                                            | All elements excluding the first |
| 数       |                                            | Following counter: length |
| 末尾     |                                            | Last element |
| 末尾以外 |                                            | All elements excluding the last |
| 目       |                                            | Following number and counter: numeric index |
| 自乗     | 平方                                       | Squared power |
| 自乗根   | 平方根                                     | Squared root |
| 長さ     | ながさ<br>大きさ<br>おおきさ<br>数<br>かず | Length |

### Punctuation and Symbols

| Punctuation / Symbol | Alternate Writing | Usage |
| -------------------- | ----------------- | ----- |
| ・・・               |                   | No-op |
| ！                   | !                 | Force functions to return null on failure<br>Force function definitions with ambiguous conjugations<br>Stop execution after debug |
| ？                   | ?                 | Boolean cast |
| 、                   | ,                 | Array element delimiter<br>Multi-condition branch condition delimiter |
| ￥                   | \\                | In interactive-mode: begin multi-line input mode |
| 〇                   |                   | Placeholder for string format |
| 「                   |                   | String start |
| 」                   |                   | String end |
| 【                   |                   | String interpolation start |
| 】                   |                   | String interpolation end |
| （                   | (                 | Block comment start |
| ）                   | )                 | Block comment end |
| ※                   |                   | Single-line comment start |

### Built-Ins

| Function           | Alternate Writing                | Documentation |
| ------------------ | -------------------------------- | ------------- |
| の乱数を発生させる |                                  | [Rand](./built_ins/rand.md) |
| ポイ捨てる         |                                  | [Dump](./built_ins/dump.md) |
| 並び替える         | ならびかえる                     | [Sort](./built_ins/sort.md) |
| 乱数の種に与える   | 乱数の種にあたえる               | [Seed Rand](./built_ins/srand.md) |
| 先頭から押し込む   | 先頭からおしこむ                 | [Unshift](./built_ins/unshift.md) |
| 先頭を引き出す     | 先頭を引きだす<br>先頭をひきだす | [Shift](./built_ins/shift.md) |
| 全部抜く           | 全部ぬく<br>全部取る<br>全部とる | [Remove All](./built_ins/remove_all.md) |
| 分割する           |                                  | [Split](./built_ins/split.md) |
| 切り上げる         | きりあげる                       | [Round Up](./built_ins/round.md) |
| 切り下げる         | きりさげる                       | [Round Down](./built_ins/round.md) |
| 切り抜く           | 切りぬく<br>きりぬく             | [Slice](./built_ins/slice.md) |
| 切り捨てる         | きりすてる                       | [Round Nearest](./built_ins/round.md) |
| 割った余りを求める | わった余りを求める<br>わったあまりを求める<br>わったあまりをもとめる | [Modulus](./built_ins/modulus.md) |
| 割る               | わる                             | [Divide](./built_ins/divide.md) |
| 対数               | たいすう                         | [Logarithm](./built_ins/logarithm.md) |
| 引き出す           | 引きだす<br>ひきだす             | [Pop](./built_ins/pop.md) |
| 引く               | ひく                             | [Subtract](./built_ins/subtract.md) |
| 投げる             | なげる                           | [Throw](./built_ins/throw.md) |
| 抜く               | ぬく<br>取る<br>とる             | [Remove](./built_ins/remove.md) |
| 押し込む           | おしこむ<br>追加する             | [Push](./built_ins/push.md) |
| 掛ける             | かける                           | [Multiply](./built_ins/multiply.md) |
| 探す               | さがす                           | [Find](./built_ins/find.md) |
| 数値化する         |                                  | [Cast to_Numeric](./built_ins/cast_to_n.md) |
| 整数化する         |                                  | [Cast to Integer](./built_ins/cast_to_i.md) |
| 繋ぐ               | つなぐ<br>結合する               | [Concatenate](./built_ins/concatenate.md) |
| 表示する           |                                  | [Display](./built_ins/display.md) |
| 言う               | いう                             | [Print](./built_ins/print.md) |
| 記入する           |                                  | [Format](./built_ins/format.md) |
| 足す               | たす                             | [Add](./built_ins/add.md) |
| 連結する           |                                  | [Join](./built_ins/join.md) |
