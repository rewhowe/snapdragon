module Tokenizer
  # rubocop:disable Layout/ExtraSpacing
  PARTICLE       = '(から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
  COUNTER        = '(つ|人|個|件|匹|文字)'.freeze      # 使用可能助数詞
  WHITESPACE     = " \t　".freeze                      # 空白文字
  NUMBER         = '0-9０-９'.freeze                   # 半角全角含め数字
  COMMA          = ',、'.freeze
  QUESTION       = '?？'.freeze
  BANG           = '!！'.freeze
  COMMENT_BEGIN  = '(（'.freeze
  COMMENT_CLOSE  = ')）'.freeze
  # rubocop:enable Layout/ExtraSpacing

  # Grammar term modifiers.
  EXACTLY_ONE  = (1..1)
  ZERO_OR_ONE  = (0..1)
  ZERO_OR_MORE = (0..Float::INFINITY)
  ONE_OR_MORE  = (1..Float::INFINITY)

  # The grammar consists of mutiple possible valid sequences.
  # Each sequence is made up of terms.
  #
  # A term represents one of:
  # 1. A token           - the next valid token in the sequence
  # 2. A branch sequence - a list of possible valid terms (an "OR" group)
  # 3. A sub sequence    - a list of successive valid terms (an "AND" group)
  #
  # Each term has a mod(ifier) which defines the number of times that the term
  # must match in order to be valid.
  #
  # The final term (terminal state) if each sequence must be EOL.
  GRAMMAR = {
    'Empty Line' => [{ mod: EXACTLY_ONE, token: Token::EOL }],

    'Assignment' => [
      { mod: EXACTLY_ONE, token: Token::ASSIGNMENT },       # ASSIGNMENT
      { mod: EXACTLY_ONE, branch_sequence: [                # (
        { mod: EXACTLY_ONE, token: Token::RVALUE },         #   RVALUE
        { mod: EXACTLY_ONE, sub_sequence: [                 #   | (
          { mod: EXACTLY_ONE, token: Token::POSSESSIVE },   #     POSSESSIVE
          { mod: EXACTLY_ONE, token: Token::PROPERTY },     #     PROPERTY
        ] },                                                #   )
      ], },                                                 # )
      { mod: ZERO_OR_ONE, token: Token::QUESTION, },        # QUESTION ?
      { mod: ZERO_OR_MORE, sub_sequence: [                  # (
        { mod: EXACTLY_ONE, token: Token::COMMA },          #   COMMA
        { mod: EXACTLY_ONE, branch_sequence: [              #   (
          { mod: EXACTLY_ONE, token: Token::RVALUE },       #     RVALUE
          { mod: EXACTLY_ONE, sub_sequence: [               #     | (
            { mod: EXACTLY_ONE, token: Token::POSSESSIVE }, #       POSSESSIVE
            { mod: EXACTLY_ONE, token: Token::PROPERTY },   #       PROPERTY
          ] },                                              #     )
        ] },                                                #   )
        { mod: ZERO_OR_ONE, token: Token::QUESTION, },      #   QUESTION ?
      ] },                                                  # ) *
      { mod: EXACTLY_ONE, token: Token::EOL },              # EOL
    ],

    'Function Def' => [
      { mod: ZERO_OR_MORE, token: Token::PARAMETER },   # PARAMETER *
      { mod: EXACTLY_ONE, token: Token::FUNCTION_DEF }, # FUNCTION_DEF
      { mod: ZERO_OR_ONE, token: Token::BANG },         # BANG ?
      { mod: EXACTLY_ONE, token: Token::EOL },          # EOL
    ],

    'Function Call' => [
      { mod: ZERO_OR_MORE, sub_sequence: [               # (
        { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },  #  POSSESSIVE ?
        { mod: EXACTLY_ONE, token: Token::PARAMETER },   #  PARAMETER
      ] },                                               # ) *
      { mod: EXACTLY_ONE, token: Token::FUNCTION_CALL }, # FUNCTION_CALL
      { mod: ZERO_OR_ONE, token: Token::BANG },          # BANG ?
      { mod: ZERO_OR_ONE, token: Token::QUESTION },      # QUESTION ?
      { mod: EXACTLY_ONE, token: Token::EOL },           # EOL
    ],

    'Return' => [
      { mod: ZERO_OR_ONE, sub_sequence: [               # (
        { mod: ZERO_OR_ONE, token: Token::POSSESSIVE }, #   POSSESSIVE ?
        { mod: EXACTLY_ONE, token: Token::PARAMETER },  #   PARAMETER
      ] },                                              # ) ?
      { mod: EXACTLY_ONE, token: Token::RETURN },       # RETURN
      { mod: EXACTLY_ONE, token: Token::EOL },          # EOL
    ],

    'Loop' => [
      { mod: ZERO_OR_ONE, sub_sequence: [                    # (
        { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },      #   POSSESSIVE ?
        { mod: EXACTLY_ONE, token: Token::PARAMETER },       #   PARAMETER
        { mod: EXACTLY_ONE, branch_sequence: [               #   (
          { mod: EXACTLY_ONE, sub_sequence: [                #     (
            { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },  #       POSSESSIVE ?
            { mod: EXACTLY_ONE, token: Token::PARAMETER },   #       PARAMETER
          ] },                                               #     )
          { mod: EXACTLY_ONE, token: Token::LOOP_ITERATOR }, #     | LOOP_ITERATOR
        ] },                                                 #   )
      ] },                                                   # ) ?
      { mod: EXACTLY_ONE, token: Token::LOOP },              # LOOP
      { mod: EXACTLY_ONE, token: Token::EOL },               # EOL
    ],

    'If Comparison' => [
      { mod: EXACTLY_ONE, branch_sequence: [                     # (
        { mod: EXACTLY_ONE, token: Token::IF },                  #   IF
        { mod: EXACTLY_ONE, token: Token::ELSE_IF },             #   | ELSE_IF
      ] },                                                       # )
      { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },            # POSSESSIVE ?
      { mod: EXACTLY_ONE, branch_sequence: [                     # (
        { mod: EXACTLY_ONE, sub_sequence: [                      #   (
          { mod: EXACTLY_ONE, token: Token::COMP_1 },            #     COMP_1
          { mod: EXACTLY_ONE, token: Token::QUESTION },          #     QUESTION
          { mod: EXACTLY_ONE, branch_sequence: [                 #     (
            { mod: EXACTLY_ONE, token: Token::COMP_2 },          #       COMP_2
            { mod: EXACTLY_ONE, token: Token::COMP_2_NOT },      #       | COMP_2
          ] },                                                   #     )
        ] },                                                     #   )
        { mod: EXACTLY_ONE, sub_sequence: [                      #   | (
          { mod: EXACTLY_ONE, token: Token::SUBJECT },           #     SUBJECT
          { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },        #     POSSESSIVE ?
          { mod: EXACTLY_ONE, branch_sequence: [                 #     (
            { mod: EXACTLY_ONE, sub_sequence: [                  #       (
              { mod: EXACTLY_ONE, branch_sequence: [             #         (
                { mod: EXACTLY_ONE, token: Token::COMP_1 },      #           COMP_1
                { mod: EXACTLY_ONE, token: Token::COMP_1_GTEQ }, #           | COMP_1_GTEQ
                { mod: EXACTLY_ONE, token: Token::COMP_1_LTEQ }, #           | COMP_1_LTEQ
              ] },                                               #         )
              { mod: EXACTLY_ONE, branch_sequence: [             #         (
                { mod: EXACTLY_ONE, token: Token::COMP_2 },      #           COMP_2
                { mod: EXACTLY_ONE, token: Token::COMP_2_NOT },  #           | COMP_2
              ] },                                               #         )
            ] },                                                 #       )
            { mod: EXACTLY_ONE, sub_sequence: [                  #       | (
              { mod: EXACTLY_ONE, token: Token::COMP_1_TO },     #         COMP_1_TO
              { mod: EXACTLY_ONE, branch_sequence: [             #         (
                { mod: EXACTLY_ONE, token: Token::COMP_2_EQ },   #           COMP_2_EQ
                { mod: EXACTLY_ONE, token: Token::COMP_2_NEQ },  #           | COMP_2_NEQ
              ] },                                               #         )
            ] },                                                 #       )
            { mod: EXACTLY_ONE, sub_sequence: [                  #       | (
              { mod: EXACTLY_ONE, token: Token::COMP_1_YORI },   #         COMP_1_YORI
              { mod: EXACTLY_ONE, branch_sequence: [             #         (
                { mod: EXACTLY_ONE, token: Token::COMP_2_LT },   #           COMP_2_YORI
                { mod: EXACTLY_ONE, token: Token::COMP_2_GT },   #           | COMP_2_GT
              ] },                                               #         )
            ] },                                                 #       )
          ] },                                                   #     )
        ] },                                                     #   )
      ] },                                                       # )
      { mod: EXACTLY_ONE, token: Token::EOL },                   # EOL
    ],

    'If Function Call' => [
      { mod: EXACTLY_ONE, branch_sequence: [             # (
        { mod: EXACTLY_ONE, token: Token::IF },          #   IF
        { mod: EXACTLY_ONE, token: Token::ELSE_IF },     #   | ELSE_IF
      ] },                                               # )
      { mod: ZERO_OR_MORE, sub_sequence: [               # (
        { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },  #  POSSESSIVE ?
        { mod: EXACTLY_ONE, token: Token::PARAMETER },   #  PARAMETER
      ] },                                               # ) *
      { mod: EXACTLY_ONE, token: Token::FUNCTION_CALL }, # FUNCTION_CALL
      { mod: ZERO_OR_ONE, token: Token::BANG },          # BANG ?
      { mod: ZERO_OR_ONE, token: Token::QUESTION },      # QUESTION ?
      { mod: EXACTLY_ONE, branch_sequence: [             # (
        { mod: EXACTLY_ONE, token: Token::COMP_2 },      #   COMP_2
        { mod: EXACTLY_ONE, token: Token::COMP_2_NOT },  #   | COMP_2
      ] },                                               # )
      { mod: EXACTLY_ONE, token: Token::EOL },           # EOL
    ],

    'Else' => [{ mod: EXACTLY_ONE, token: Token::ELSE }, { mod: EXACTLY_ONE, token: Token::EOL }],

    'Next' => [{ mod: EXACTLY_ONE, token: Token::NEXT }, { mod: EXACTLY_ONE, token: Token::EOL }],

    'Break' => [{ mod: EXACTLY_ONE, token: Token::BREAK }, { mod: EXACTLY_ONE, token: Token::EOL }],

    'No Op' => [{ mod: EXACTLY_ONE, token: Token::NO_OP }, { mod: EXACTLY_ONE, token: Token::EOL }],

    'Debug' => [
      { mod: EXACTLY_ONE, token: Token::DEBUG }, # DEBUG
      { mod: ZERO_OR_ONE, token: Token::BANG },  # BANG ?
      { mod: EXACTLY_ONE, token: Token::EOL }    # EOL
    ],
  }.freeze
end
