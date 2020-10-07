module Tokenizer
  TOKEN_SEQUENCE = {
    Token::EOL => [
      Token::EOL,
      Token::FUNCTION_CALL,
      Token::FUNCTION_DEF,
      Token::RETURN,
      Token::NO_OP,
      Token::ASSIGNMENT,
      Token::PARAMETER,
      Token::IF,
      Token::ELSE_IF,
      Token::ELSE,
      Token::LOOP,
      Token::NEXT,
      Token::BREAK,
    ],
    Token::ASSIGNMENT => [
      Token::VARIABLE,
    ],
    Token::VARIABLE => [
      Token::EOL,
      Token::QUESTION,
      Token::COMMA,
    ],
    Token::PARAMETER => [
      Token::PARAMETER,
      Token::FUNCTION_DEF,
      Token::FUNCTION_CALL,
      Token::RETURN,
      Token::LOOP,
      Token::LOOP_ITERATOR,
    ],
    Token::FUNCTION_DEF => [
      Token::EOL,
    ],
    Token::FUNCTION_CALL => [
      Token::EOL,
      Token::QUESTION,
      Token::BANG,
    ],
    Token::RETURN => [
      Token::EOL,
    ],
    Token::NO_OP => [
      Token::EOL,
    ],
    Token::QUESTION => [
      Token::EOL,
      Token::COMP_3,
      Token::COMP_3_NOT, # next: COMP_3
    ],
    Token::BANG => [
      Token::EOL,
      Token::QUESTION,
    ],
    Token::COMMA => [
      Token::VARIABLE,
    ],
    Token::IF => [
      Token::PARAMETER,
      Token::FUNCTION_CALL,
      Token::COMP_1,
      Token::COMP_2,
    ],
    Token::ELSE_IF => [
      Token::PARAMETER,
      Token::COMP_1,
      Token::COMP_2,
    ],
    Token::ELSE => [
      Token::EOL,
    ],
    Token::COMP_1 => [
      Token::COMP_2,
      Token::COMP_2_TO,
      Token::COMP_2_YORI,
      Token::COMP_2_GTEQ,
      Token::COMP_2_LTEQ,
    ],
    Token::COMP_2 => [
      Token::QUESTION,
    ],
    Token::COMP_2_TO => [
      Token::COMP_3_EQ,  # next: COMP_3
      Token::COMP_3_NEQ, # next: COMP_3
    ],
    Token::COMP_2_YORI => [
      Token::COMP_3_LT, # next: COMP_3
      Token::COMP_3_GT, # next: COMP_3
    ],
    Token::COMP_2_GTEQ => [
      Token::COMP_3,
    ],
    Token::COMP_2_LTEQ => [
      Token::COMP_3,
    ],
    Token::COMP_3 => [
      Token::EOL,
    ],
    Token::LOOP_ITERATOR => [
      Token::LOOP,
    ],
    Token::LOOP => [
      Token::EOL,
    ],
    Token::NEXT => [
      Token::EOL,
    ],
    Token::BREAK => [
      Token::EOL,
    ],
  }.freeze
end
