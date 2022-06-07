# Planning

---

## v2.2.0

### File IO

* Additional built-ins?
  * Delete (key) `対象列から 「キー」と いうキーを取り除く`

* Built-ins
  * Open `「ファイル名」を 開く`
  * Close `ファイルハンドルを 閉じる`
  * Read Char `ファイルハンドルから 一文字読み込む`
  * Read Line `ファイルハンドルを 一行読み込む`
  * Read All `ファイルハンドルを 読み込む`, alias `全部読み込む`
  * Write `ファイルハンドルに 「テキスト」を 書き込む`
    * Syntax: `|%(書き込|[書か]きこ)(む|ん[でだ])`
  * Copy: `「ファイル名」を 「ファイル名」に コピーする`
  * Move: `「ファイル名」を 「ファイル名」に 移動する`
  * Delete: `「ファイル名」を 削除する`

## Implicit それ for more built-ins

* Allow implicit それ for more built-ins
  * `implicable?` field in built-ins definitions

## Regex

* Match condition `主語が 「正規表現」に 一致する`
* Capture?
* Replace `対象文字列を 「正規表現」で 「置換文字列」に 置き換える`

### Load Files

* It might be neat to add a way to load other Snapdragon files. This would let anyone make plugins for Snapdragon, written entirely in Snapdragon.
* ~~Need some sort of directive... Like `→「プラグイン」` or something?~~
* ~~Or built-in `「プラグイン名」を 導入する` (limited to root scope)~~
* Include XXX from YYY: `「プラグイン名」から 「変数名」、「Aと Bに 関数名」、... を 導入する`
  * Includes `変数名` and `関数名とに` (func key) from `プラグイン名` (relative or absolute path)
  * `BOL PARAMETER ( RVALUE COMMA ) * PARAMETER INCLUDE EOL`
  * Like python's `from XXX import YYY` or perl's `use XXX qw(YYY)`
    * Because I prefer explicitness over ambiguity
* Need a way to solve naming collisions... (Can't think of a way to articulately provide namespaces)
  * ~~Method rename: `Aと Bに 新関数名とは 旧関数名 こと` (replace `旧関数名とに` with `新関数名とに`)~~
  * `「プラグイン名」から 「新関数名」と する 「Aと Bに 旧関数名」を 導入する`
* Imported on processor side:
  * Load the file (maybe pass it to a new tokenizer + reader? reuse something like token printer?)
  * Process in an anonymous `main` level scope
  * Steal the requested variables / functions (including body tokens)
  * Inject into current scope

```
ファイル名を オプションと CSV読み込むとは
　「ファイル名」を 開く
　ファイルは それ

　ヘッダーは 無
　もし オプションの 「ヘッダーあり？」が あれば
　　ファイルを 読み込んで
　　それを 「,」で 分割する
　　ヘッダーは それ

　　値列を ヘッダーに組み合わせるとは
　　　組み合わせた列は 連想配列
　　　値列の 長さから 1を 引いて
　　　0から それまで 繰り返す
　　　　指数は それ
　　　　カラム名は ヘッダーの 指数
　　　　組み合わせた列の カラム名は 値列の 指数
　　　組み合わせた列と なる

　結果列は 配列
　繰り返す
　　ファイルから 先頭を引き出す
　　もし それが 無 ならば
　　　終わり
　　ファイルを 読み込んで
　　それを 「,」で 分割して
　　行は それ

　　もし ヘッダーが あれば
　　　行を ヘッダーに組み合わせる
　　　行は それ

　　結果列に 行を 押し込む

　結果列を 返す

※ TODO write
```

### v2.2.0 Release

* Run rspec and rubocop one last time
* Update README and README_jp with version history
* Update version string in snapdragon

## v2.2.0

### Sleep

* Built-in for sleep

### Networking

* Something for basic network requests?
  * `urlに 送信する`
  * `urlに verbで 送信する`
  * `urlに verbで dataを 送信する`
* alias `要求する`
* Might need something to convert between JSON-formatted strings and SdArrays
* How to accept non-string (csv/json?) responses?

---

## Back Burner

Changes which seem interesting but low priority.

### Alternate Assignment

```
【変数】を 【値】と する
```

Grammar:

```
BOL POSSESSIVE ? PARAMETER POSSESSIVE ? PARAMETER SURU
```

Tokens:

```
POSSESSIVE ? ASSIGNMENT POSSESSIVE ? RVALUE
```

* Check for read-only properties
* Syntax for する (aux?)

### Alternate Return

```
【変数｜値】の こと
```

Grammar:

```
POSSESSIVE ? POSSESSIVE RETURN
```

(may use a different keyword instead if `RETURN` grammar is too complicated)

Tokens: same as grammar

### Function Call Result

```
【変数】は 【関数呼び出しタ形】 結果
```

Grammar:

* assignment
  * extract prop / value / etc

```
BOL
ASSIGNMENT
( RVALUE | POSSESSIVE PROPERTY | ( POSSESSIVE ? PARAMETER ) * FUNCTION_CALL RESULT )
QUESTION ?
(
  COMMA
  ( RVALUE | POSSESSIVE PROPERTY | ( POSSESSIVE ? PARAMETER ) * FUNCTION_CALL RESULT )
  QUESTION ?
) *
EOL
```

* as subject or comp of `IF` / `ELSE_IF`

```
BOL
( IF | ELSE_IF )
POSSESSIVE ?
(
  COMP_1 QUESTION ( COMP_2 | COMP_2_NOT )
  | SUBJECT POSSESSIVE ? (
    ( COMP_1 | ( COMP_1_TO COMP_1_EQ ) | COMP_1_GTEQ | COMP_1_LTEQ | COMP_1_EMP ) ( COMP_2 | COMP_2_NOT )
    | COMP_1_YORI ( COMP_2_LT | COMP_2_GT )
    | COMP_1_IN ( COMP_2_BE | COMP_2_NBE )
  )
)
EOL

　↓

BOL
( IF | ELSE_IF )
(
  POSSESSIVE ? COMP_1 QUESTION ( COMP_2 | COMP_2_NOT )
  | ( POSSESSIVE | ( POSSESSIVE ? PARAMETER ) * FUNCTION_CALL ) ? SUBJECT
    ( POSSESSIVE | ( POSSESSIVE ? PARAMETER ) * FUNCTION_CALL ) ? (
      ( COMP_1 | ( COMP_1_TO COMP_1_EQ ) | COMP_1_GTEQ | COMP_1_LTEQ | COMP_1_EMP ) ( COMP_2 | COMP_2_NOT )
      | COMP_1_YORI ( COMP_2_LT | COMP_2_GT )
      | COMP_1_IN ( COMP_2_BE | COMP_2_NBE )
    )
)
EOL
```

Need check for `RESULT` in `SUBJECT` and in all `COMP_1〇〇`

function call must be past-tense

Tokens:

* hit 結果, place `RESULT` at beginning of stack (after assignment or after `IF`, `ELSE_IF`, `SUBJECT`, or `AND` or `OR`)
* more generally (?): `RESULT` should go before the first of: `FUNCTION_CALL`, `PARAMETER`, or `POSSESSIVE` (stepping backwards)

### Test Function

* Need to allow branch conditions in array assignment...

`【配列】を 試す`, `[[[引数5と] 引数4と] 引数3と] 引数2と 引数1を 試す`

* name: `test`
* takes up to 5 parameters OR an array of conditions
* returns 全部 (`COMP_1_TEST_ALL`) if all are true, いずれか (`COMP_1_TEST_SOME`) if some are true, or null if none are true

```
add to conjunctive condition:

それが 全部 通り、
それが いずれか 通り、

| ( COMP_1_TEST_ALL | COMP_1_TEST_SOME ) COMP_2_TEST_I


add to closing condition

それが 全部 通れば
それが いずれか 通れば

| ( COMP_1_TEST_ALL | COMP_1_TEST_SOME ) COMP_2_TEST
```

`COMP_1_TEST` = `通り` or `とおり`

```
a || b && c || d

a|b && c|d

もし aと bを 試した 結果が いずれか 通り、
かつ cと dを 試した 結果が いずれか 通れば

IF  PARAMETER PARAMETER FUNCTION_CALL SUBJECT COMP_1_TEST_ALL  COMP_2_TEST_I COMMA
AND PARAMETER PARAMETER FUNCTION_CALL SUBJECT COMP_1_TEST_SOME COMP_2_TEST
resulting tokens:
IF COMP_EQ RESULT PARAMETER PARAMETER FUNCTION_CALL COMP_1_TEST_ALL
   COMP_EQ RESULT PARAMETER PARAMETER FUNCTION_CALL COMP_1_TEST_SOME
```
