# Planning

---

## v2.0.0

### Empty Comparison

```
もし 【列】が 空 ならば
```

* add new token `COMP_1_EMPTY` (treat like `COMP_1`)

Grammar:

```
BOL
( IF | ELSE_IF )
POSSESSIVE ?
(
  COMP_1 QUESTION ( COMP_2 | COMP_2_NOT )
  | SUBJECT POSSESSIVE ? (
    ( COMP_1 | COMP_1_GTEQ | COMP_1_LTEQ | COMP_1_EMPTY ) ( COMP_2 | COMP_2_NOT )
    | COMP_1_TO ( COMP_2_EQ | COMP_2_NEQ )
    | COMP_1_YORI ( COMP_2_LT | COMP_2_GT )
  )
)
EOL
```

* Validate `SUBJECT` is a plain `RVALUE` with no preceding `POSSESSIVE`
  * (No longer a valid solution because of `キー列` property)

Tokens:

```
IF〇〇 SUBJECT COMP_1_EMPTY COMP_2〇〇 → COMP_EQ 0 POSSESSIVE PROPERTY[PROP_LEN]
```

* Update documentation!

### More Fluent Equals

```
もし 俺が持ってるポケモンの 数が 友達が持ってるポケモンの 数と 同じ ならば
```

New Grammar:

```
BOL
( IF | ELSE_IF )
POSSESSIVE ?
(
  COMP_1 QUESTION ( COMP_2 | COMP_2_NOT )
  | SUBJECT POSSESSIVE ? (
    ( COMP_1 | COMP_1_GTEQ | COMP_1_LTEQ | COMP_1_EMPTY | ( COMP_1_TO COMP_2_EQ ) ) ( COMP_2 | COMP_2_NOT )
    | COMP_1_YORI ( COMP_2_LT | COMP_2_GT )
  )
)
EOL
```

* will need to modify some grammar below
* of course, update documentation

### Inside Array Condition

```
もし ホゲが フガの 中に あれば
もし ホゲが フガの 中に なければ
```

Grammar:

```
SUBJECT POSSESSIVE ? POSSESSIVE INSIDE ( INSIDE_YES | INSIDE_NO )
```

* あれば、なければ、いれば、いなければ、ある、いる、ない、あり、い、なく、いなく
* Also: `INSIDE_YES_U` for "adjectival"  (for `while`), `INSIDE_YES_I` for "conjunctive" (for multiple condition)
* Reserve `ある` and `いる`

### Multiple Condition Branch

* should combine if-condition and if-function-call
  * possibly: `( POSSESSIVE ? COMP_1 | ( POSSESSIVE ? PARAMETER ) * FUNCTION_CALL BANG ? ) QUESTION`

```
もし 左の 長さが 0？ ならば
　終わり
または 右の 長さが 0？ ならば
　終わり

BOL ( IF | ELSE_IF ) ( POSSESSIVE ? SUBJECT ? POSSESSIVE ? (
                                                              ( COMP_1 | COMP_1_GTEQ | COMP_1_LTEQ ) COMP_2
                                                              | COMP_1_TO ( COMP_2_EQ | COMP_2_NEQ )
                                                              | COMP_1_YORI ( COMP_2_LT | COMP_2_GT )
                                                            ) EOL

  ↓

もし 左の 長さが 0、または 右の 長さが 0 ならば

BOL
( IF | ELSE_IF )
(
  (
    POSSESSIVE ? COMP_1 QUESTION
    | POSSESSIVE ? SUBJECT POSSESSIVE ? (
      ( COMP_1 | COMP_1_GTEQ | COMP_1_LTEQ ) COMP_2_NOT_KU ?
      | COMP_1_TO ( COMP_2_EQ_KU | COMP_2_NEQ_KU )
      | COMP_1_YORI ( COMP_2_LT_KU | COMP_2_GT_KU )
    )
  )
  COMMA ( COMP_AND | COMP_OR )
) *
(
  POSSESSIVE ? COMP_1 QUESTION ( COMP_2 | COMP_2_NOT )
  | POSSESSIVE ? SUBJECT POSSESSIVE ? (
    ( COMP_1 | COMP_1_GTEQ | COMP_1_LTEQ ) ( COMP_2 | COMP_2_NOT )
    | COMP_1_TO ( COMP_2_EQ | COMP_2_NEQ )
    | COMP_1_YORI ( COMP_2_LT | COMP_2_GT )
  )
)
EOL
```

* maybe don't need `COMP_1_TO` and `COMP_2_EQ` / `COMP_2_NEQ`?
  * remove and rename `COMP_2` to `COMP_2_NOT` to replace
* will probably require re-adjusting after `RESULT` feature
* `COMP_2〇〇_KU` should be or `〜く` (conjunction), then regular `COMP_2〇〇` remains `〜ければ`
* eat newlines after comma (as usual)


### While Loop

examples:

```
ほげ？ である限り 繰り返す
BOL RVALUE QUESTION WHILE LOOP

ほげの 長さ？ である限り 繰り返す
BOL POSSESSIVE PROPERTY QUESTION WHILE LOOP


Note: ほげが 1より 大きい である限り 繰り返す weird (see below)
Instead: ほげが 1より 大きい 間 繰り返す


ほげが 空 である限り 繰り返す
BOL SUBJECT COMP_1_EMPTY WHILE LOOP


ほげを ほげた 結果が 0以上 である限り 繰り返す
BOL PARAMETER FUNCTION_CALL SUBJECT COMP_1_GTEQ WHILE LOOP
resulting tokens:
COMP_GTEQ RESULT PARAMETER FUNCTION_CALL 0 WHILE LOOP


ほげを ほげた 結果が 1より 大きい 間 繰り返す
BOL PARAMETER FUNCTION_CALL SUBJECT COMP_1_YORI COMP_2_GT_I WHILE LOOP
resulting tokens:
COMP_GT RESULT PARAMETER FUNCTION_CALL 1 WHILE LOOP


Note: ホゲが 1より 大きくない 間 繰り返す is not possible
Instead: ホゲが 1以下 である限り 繰り返す


aと bを 試した 結果が いずれか 通り、
かつ cと dを 試した 結果が いずれか 通る 間 繰り返す
BOL      PARAMETER PARAMETER FUNCTION_CALL SUBJECT COMP_1_TEST_ALL  COMP_2_TEST_I COMMA
COMP_AND PARAMETER PARAMETER FUNCTION_CALL SUBJECT COMP_1_TEST_SOME COMP_2_TEST_U WHILE LOOP

---

BOL
(
  (
    POSSESSIVE ? COMP_1 QUESTION
    | POSSESSIVE ? SUBJECT POSSESSIVE ? (
      ( COMP_1 | COMP_1_GTEQ | COMP_1_LTEQ ) COMP_2_NOT_KU
      | COMP_1_TO ( COMP_2_EQ_KU | COMP_2_NEQ_KU )
      | COMP_1_YORI ( COMP_2_LT_KU | COMP_2_GT_KU )
      | ( COMP_1_TEST_ALL | COMP_1_TEST_SOME ) COMP_2_TEST_I
    )
  )
  COMMA ( COMP_AND | COMP_OR )
) *
(
  POSSESSIVE ? COMP_1 QUESTION ( COMP_2 | COMP_2_NOT )
  | POSSESSIVE ? SUBJECT POSSESSIVE ? (
    ( COMP_1 | COMP_1_GTEQ | COMP_1_LTEQ )
    | COMP_1_TO ( COMP_2_EQ_I | COMP_2_NEQ_I )
    | COMP_1_YORI ( COMP_2_LT_I | COMP_2_GT_I )
    | ( COMP_1_TEST_ALL | COMP_1_TEST_SOME ) COMP_2_TEST_U
  )
)
( WHILE | WHILE_NOT )
LOOP
```

* extract `AND` / `OR` block (conjunctive condition) from `IF` / `ELSE_IF`
* closing condition is NOT the same

`WHILE` or `WHILE_NOT` succeeds:

* である限り: `COMP_1`, `COMP_1_GTEQ`, `COMP_1_LTEQ`, `COMP_EMPTY`
* 間: `COMP_2_EQ_I`, `COMP_2_NEQ_I`, `COMP_2_LT_I`, `COMP_2_GT_I`, `COMP_2_TEST_U`

`COMP_2〇〇_I` should be `〜い`

### Argv

* Reserve `引数列`
* 引数列 special variable?
* Mostly handled by ruby's native `ARGV`

### Try-Catch

* Try: `試す`
* Catch: `例外があれば` or `問題があれば` (space?)
* Error message is stored in `それ`

### Additional Math

Exponentiation

```
Ｖ1の Ｖ2乗 = V1^V2
```

* Simply a new property: `PROP_EXP`
* `その乗` = sub type: `VAR_SORE`

Root

```
Ｖ1の Ｖ2乗根 = root_V2(V1) (ex. root_2(25) = 5)
```

* Simply a new property: `PROP_ROOT`
* `その乗根` = sub type: `VAR_SORE`

Log

```
底を V1と する V2の対数 = log_V1(V2) (ex. log_2(8) = 3)
```

Grammar:

```
BOL LOG_BEGIN PARAMETER SURU LOG_CLOSE
```

Write an example for finding number of 1 bits in a number or binary representation

```
数値で ビット計算するとは
　ビット数は 0
　ビット表現は 「」

　底を 2と する 数値の対数
　それを 整数化して

　それから 0まで 繰り返す
　　今の乗冪は 2の その乗

　　もし 今の乗冪が 数値以下 ならば
　　　ビット数に 1を 足す
　　　ビット表現に 「1」を 追加する
　　　数値は 数値から 今の乗冪を 引いた 結果
　　でなければ
　　　ビット表現に 「0」を 追加する

　結果列は ビット数、ビット表現
　返す
```

* Need to allow numbers in POSSESSIVE matcher
* update documentation
  * move Array / String Properties to just Properties
* update tests
* update syntax

### Short Static Loop

`N回 繰り返す`

### Interactive

* Create new reader with loop accepting input

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
    ( COMP_1 | COMP_1_GTEQ | COMP_1_LTEQ ) ( COMP_2 | COMP_2_NOT )
    | COMP_1_TO ( COMP_2_EQ | COMP_2_NEQ)
    | COMP_1_YORI ( COMP_2_LT | COMP_2_GT )
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
      ( COMP_1 | COMP_1_GTEQ | COMP_1_LTEQ ) ( COMP_2 | COMP_2_NOT )
      | COMP_1_TO ( COMP_2_EQ | COMP_2_NEQ)
      | COMP_1_YORI ( COMP_2_LT | COMP_2_GT )
    )
)
EOL
```

Need check for `RESULT` in `SUBJECT` and in all `COMP_1〇〇`

function call must be past-tense

Tokens:

* hit 結果, place `RESULT` at beginning of stack (after assignment or after `IF`, `ELSE_IF`, `SUBJECT`, or `COMP_AND` or `COMP_OR`)
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

IF       PARAMETER PARAMETER FUNCTION_CALL SUBJECT COMP_1_TEST_ALL  COMP_2_TEST_I COMMA
COMP_AND PARAMETER PARAMETER FUNCTION_CALL SUBJECT COMP_1_TEST_SOME COMP_2_TEST
resulting tokens:
IF COMP_EQ RESULT PARAMETER PARAMETER FUNCTION_CALL COMP_1_TEST_ALL
   COMP_EQ RESULT PARAMETER PARAMETER FUNCTION_CALL COMP_1_TEST_SOME
```