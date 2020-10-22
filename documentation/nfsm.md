# Non-Deterministic Finite State Diagrams / 非決定性有限状態図

## ASSIGNMENT

```mermaid
graph LR
  BOL --> ASSIGNMENT

  ASSIGNMENT --> RVALUE
  ASSIGNMENT --> PROPERTY

  RVALUE --> EOL
  RVALUE --> QUESTION
  RVALUE --> COMMA

  PROPERTY --> ATTRIBUTE

  ATTRIBUTE --> EOL
  ATTRIBUTE --> QUESTION
  ATTRIBUTE --> COMMA

  COMMA --> RVALUE
  COMMA --> PROPERTY

  QUESTION --> COMMA
  QUESTION --> EOL
```

## FUNCTION\_DEF / FUNCTION\_CALL

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

```mermaid
graph LR
  BOL --> PARAMETER
  BOL --> FUNCTION_CALL
  BOL --> PROPERTY

  PARAMETER --> PARAMETER
  PARAMETER --> FUNCTION_CALL

  FUNCTION_CALL --> EOL
  FUNCTION_CALL --> QUESTION
  FUNCTION_CALL --> BANG

  PROPERTY --> PARAMETER

  BANG --> QUESTION

  QUESTION --> EOL
```

## RETURN

```mermaid
graph LR
  BOL --> PARAMETER
  BOL --> RETURN

  PARAMETER --> RETURN

  RETURN --> EOL
```

## LOOP / LOOP\_ITERATOR / NEXT / BREAK

```mermaid
graph LR
  BOL --> PARAMETER_1[PARAMETER]
  BOL --> LOOP

  PARAMETER_1[PARAMETER] --> PARAMETER_2[PARAMETER]
  PARAMETER_2[PARAMETER] --> LOOP_ITERATOR

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

```mermaid
graph LR
  BOL --> IF

  IF --> COMP_1
  IF --> COMP_2
  IF --> PROPERTY_1[PROPERTY]

  COMP_1 --> COMP_2
  COMP_1 --> COMP_2_TO
  COMP_1 --> COMP_2_YORI
  COMP_1 --> COMP_2_GTEQ
  COMP_1 --> COMP_2_LTEQ
  COMP_1 --> PROPERTY_2[PROPERTY]

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
    PROPERTY_1[PROPERTY] --> COMP_1
  end

  subgraph comparator 2
    PROPERTY_1[PROPERTY] --> COMP_2

    PROPERTY_2[PROPERTY] --> COMP_2
    PROPERTY_2[PROPERTY] --> COMP_2_TO
    PROPERTY_2[PROPERTY] --> COMP_2_YORI
    PROPERTY_2[PROPERTY] --> COMP_2_GTEQ
    PROPERTY_2[PROPERTY] --> COMP_2_LTEQ
  end
```

```mermaid
graph LR
  BOL --> IF

  IF --> PARAMETER
  IF --> PROPERTY
  IF --> FUNCTION_CALL

  subgraph comparator 2
    PARAMETER --> PARAMETER
    PARAMETER --> PROPERTY
    PARAMETER --> FUNCTION_CALL

    PROPERTY --> PARAMETER
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

**ELSE\_IF** follows the same sequence as **IF**.

```mermaid
graph LR
  BOL --> ELSE

  ELSE --> EOL
```
