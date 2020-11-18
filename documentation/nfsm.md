# Non-Deterministic Finite State Diagrams / 非決定性有限状態図

The diagrams below describe the different sequences supported by 金魚草's grammar. Each sequence is shown in a sort of pseudo-regex format, and in Mermaid syntax which needs to be rendered by a supporting markdown editor.

## ASSIGNMENT

`BOL ASSIGNMENT ( RVALUE | ( POSSESSIVE PROPERTY ) ) QUESTION ? ( COMMA ( RVALUE | ( POSSESSIVE PROPERTY ) ) QUESTION ? ) * EOL`

```mermaid
graph LR
  BOL --> ASSIGNMENT

  ASSIGNMENT --> RVALUE
  ASSIGNMENT --> POSSESSIVE

  RVALUE --> EOL
  RVALUE --> QUESTION
  RVALUE --> COMMA

  POSSESSIVE --> PROPERTY

  PROPERTY --> EOL
  PROPERTY --> QUESTION
  PROPERTY --> COMMA

  COMMA --> RVALUE
  COMMA --> POSSESSIVE

  QUESTION --> COMMA
  QUESTION --> EOL
```

## FUNCTION\_DEF / FUNCTION\_CALL

`BOL PARAMETER * FUNCTION_DEF BANG ? EOL`

```mermaid
graph LR
  BOL --> PARAMETER
  BOL --> FUNCTION_DEF

  PARAMETER --> PARAMETER
  PARAMETER --> FUNCTION_DEF

  FUNCTION_DEF --> EOL
  FUNCTION_DEF --> BANG

  BANG --> EOL
```

`BOL ( POSSESSIVE ? PARAMETER ) * FUNCTION_CALL BANG ? QUESTION ? EOL`

```mermaid
graph LR
  BOL --> PARAMETER
  BOL --> FUNCTION_CALL
  BOL --> POSSESSIVE

  PARAMETER --> PARAMETER
  PARAMETER --> FUNCTION_CALL

  FUNCTION_CALL --> EOL
  FUNCTION_CALL --> BANG
  FUNCTION_CALL --> QUESTION

  POSSESSIVE --> PARAMETER

  BANG --> QUESTION

  QUESTION --> EOL
```

## RETURN

`BOL ( POSSESSIVE ? PARAMETER ) ? RETURN EOL`

```mermaid
graph LR
  BOL --> PARAMETER
  BOL --> POSSESSIVE
  BOL --> RETURN

  PARAMETER --> RETURN

  POSSESSIVE --> PARAMETER

  RETURN --> EOL
```

## LOOP / LOOP\_ITERATOR / NEXT / BREAK

`BOL ( PARAMETER ( PARAMETER | LOOP_ITERATOR ) ) ? LOOP EOL`

```mermaid
graph LR
  BOL --> PARAMETER_1[PARAMETER]
  BOL --> POSSESSIVE_1[POSSESSIVE]
  BOL --> LOOP

  PARAMETER_1[PARAMETER] --> PARAMETER_2[PARAMETER]
  PARAMETER_1[PARAMETER] --> LOOP_ITERATOR
  PARAMETER_1[PARAMETER] --> POSSESSIVE_2[PARAMETER]

  PARAMETER_2[PARAMETER] --> LOOP

  POSSESSIVE_1[POSSESSIVE] --> PARAMETER_1[PARAMETER]

  POSSESSIVE_2[POSSESSIVE] --> PARAMETER_2[PARAMETER]

  LOOP_ITERATOR --> LOOP

  LOOP --> EOL
```

```mermaid
graph LR
  BOL --> NEXT

  NEXT --> EOL
```

```mermaid
graph LR
  BOL --> BREAK

  BREAK --> EOL
```

## IF / ELSE\_IF / ELSE

```rb
BOL ( IF | ELSE_IF ) ( POSSESSIVE ? COMP_1 ) ? POSSESSIVE ? (
                                                              ( COMP_2 QUESTION | COMP_2_GTEQ | COMP_2_LTEQ ) COMP_3
                                                              | COMP_2_TO ( COMP_3_EQ | COMP_3_NEQ)
                                                              | COMP_2_YORI ( COMP_3_LT | COMP_3_GT )
                                                            ) EOL
```

```mermaid
graph LR
  BOL --> IF[IF / ELSE_IF]

  IF[IF / ELSE_IF] --> COMP_1
  IF[IF / ELSE_IF] --> COMP_2
  IF[IF / ELSE_IF] --> POSSESSIVE_1[POSSESSIVE]

  COMP_1 --> COMP_2
  COMP_1 --> COMP_2_TO
  COMP_1 --> COMP_2_YORI
  COMP_1 --> COMP_2_GTEQ
  COMP_1 --> COMP_2_LTEQ
  COMP_1 --> POSSESSIVE_2[POSSESSIVE]

  COMP_2 --> QUESTION

  QUESTION --> COMP_3
  QUESTION --> COMP_3_NOT

  COMP_3 --> EOL

  COMP_3_NOT --> EOL

  COMP_2_TO --> COMP_3_EQ
  COMP_2_TO --> COMP_3_NEQ

  COMP_3_EQ --> EOL

  COMP_3_NEQ --> EOL

  COMP_2_YORI --> COMP_3_LT
  COMP_2_YORI --> COMP_3_GT

  subgraph comparator 3
    COMP_3_NOT

    COMP_3_LT --> COMP_3

    COMP_3_GT --> COMP_3

    COMP_3_EQ

    COMP_3_NEQ
  end

  COMP_2_GTEQ --> COMP_3

  COMP_2_LTEQ --> COMP_3

  subgraph comparator 1
    POSSESSIVE_1[POSSESSIVE] --> COMP_1
  end

  subgraph comparator 2
    POSSESSIVE_1[POSSESSIVE] --> COMP_2

    POSSESSIVE_2[POSSESSIVE] --> COMP_2
    POSSESSIVE_2[POSSESSIVE] --> COMP_2_TO
    POSSESSIVE_2[POSSESSIVE] --> COMP_2_YORI
    POSSESSIVE_2[POSSESSIVE] --> COMP_2_GTEQ
    POSSESSIVE_2[POSSESSIVE] --> COMP_2_LTEQ
  end
```

`BOL ( IF | ELSE_IF ) ( POSSESSIVE ? PARAMETER ) * FUNCTION_CALL BANG ? QUESTION ? ( COMP_3 | COMP_3_NOT ) EOL`

```mermaid
graph LR
  BOL --> IF[IF / ELSE_IF]

  IF[IF / ELSE_IF ] --> PARAMETER
  IF[IF / ELSE_IF ] --> POSSESSIVE
  IF[IF / ELSE_IF ] --> FUNCTION_CALL

  subgraph comparator 2
    PARAMETER --> PARAMETER
    PARAMETER --> POSSESSIVE
    PARAMETER --> FUNCTION_CALL

    POSSESSIVE --> PARAMETER
  end

  FUNCTION_CALL --> QUESTION

  QUESTION --> COMP_3
  QUESTION --> COMP_3_NOT

  COMP_3 --> EOL

  COMP_3_NOT --> EOL

  subgraph comparator 3
    COMP_3
    COMP_3_NOT
  end
```

```mermaid
graph LR
  BOL --> ELSE

  ELSE --> EOL
```

## MISC

```mermaid
graph LR
  BOL --> NO_OP

  NO_OP --> EOL
```

```mermaid
graph LR
  BOL --> DEBUG

  DEBUG --> BANG
  DEBUG --> EOL

  BANG --> EOL
```
