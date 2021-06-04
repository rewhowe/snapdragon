# Planning

---

## v2.0.0

### Rename Assignment Token

* ASSIGNMENT → TOPIC
(Also let's move resolvers out to another module?)

### Argv

* Reserve `引数列`
* 引数列 special variable?
* Mostly handled by ruby's native `ARGV`
* update manual
* update manual jp
* update nfsm
* update syntax

### Try-Catch

* Try: `試す`
* Catch: `例外があれば` or `問題があれば` (space?)
* Error message is stored in `それ`
* Abstract `with scope` logic (dup'd in if-statements, loops, whiles)
* update manual
* update manual jp
* update nfsm
* update syntax

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

## v2.1.0

### Interactive

* Create new reader with loop accepting input

### Performance

* Extract debug log formatting (at least for processor?) so that no extra logic is performed unless debugging is on
  * Particularly: for every function call, arguments are resolved TWICE
  * maybe use optional blocks? `yield if block_given?`
* Find a way to avoid copying sd arrays every time they're resolved (ONLY copy when they're modified?)

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