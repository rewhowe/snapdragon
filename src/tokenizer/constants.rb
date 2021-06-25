module Tokenizer
  # rubocop:disable Layout/ExtraSpacing
  PARTICLE      = '(から|と|に|へ|まで|で|を)'.freeze # 使用可能助詞
  COUNTER       = '(つ|人|個|件|匹|文字)'.freeze      # 使用可能助数詞
  WHITESPACE    = " \t　".freeze                      # 空白文字
  NUMBER        = '0-9０-９'.freeze                   # 半角全角含め数字
  COMMA         = ',、'.freeze
  QUESTION      = '?？'.freeze
  BANG          = '!！'.freeze
  COMMENT_BEGIN = '(（'.freeze
  COMMENT_CLOSE = ')）'.freeze
  # rubocop:enable Layout/ExtraSpacing

  # Special Globals
  ID_SORE = 'それ'.freeze
  ID_ARE  = 'あれ'.freeze
  ID_ARGV = '引数列'.freeze
  ID_ERR  = '例外'.freeze
  # Other common values
  ID_TRUE  = '真'.freeze
  ID_FALSE = '偽'.freeze
  ID_NULL  = '無'.freeze

  # Grammar term modifiers.
  EXACTLY_ONE  = (1..1)
  ZERO_OR_ONE  = (0..1)
  ZERO_OR_MORE = (0..Float::INFINITY)
  ONE_OR_MORE  = (1..Float::INFINITY)

  # Optional block for chaining multiple conditions in IF, ELSE_IF, and WHILE.
  # See GRAMMAR below.
  MULTI_CONDITION_SEQUENCE = { mod: ZERO_OR_MORE, sub_sequence: [  # (
    { mod: EXACTLY_ONE, branch_sequence: [                         #   (
      # truthy check
      { mod: EXACTLY_ONE, sub_sequence: [                          #     (
        { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },            #       POSSESSIVE ?
        { mod: EXACTLY_ONE, token: Token::COMP_1 },                #       COMP_1
        { mod: EXACTLY_ONE, token: Token::QUESTION },              #       QUESTION
        { mod: ZERO_OR_ONE, token: Token::COMP_2_NOT_CONJ },       #       COMP_2_NOT_CONJ ?
      ] },                                                         #     )
      # function call
      { mod: EXACTLY_ONE, sub_sequence: [                          #     | (
        { mod: ZERO_OR_MORE, sub_sequence: [                       #       (
          { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },          #        POSSESSIVE ?
          { mod: EXACTLY_ONE, token: Token::PARAMETER },           #        PARAMETER
        ] },                                                       #       ) *
        { mod: EXACTLY_ONE, token: Token::FUNCTION_CALL },         #       FUNCTION_CALL
        { mod: ZERO_OR_ONE, token: Token::BANG },                  #       BANG ?
        { mod: ZERO_OR_ONE, token: Token::QUESTION },              #       QUESTION ?
        { mod: ZERO_OR_ONE, token: Token::COMP_2_NOT_CONJ },       #       COMP_2_NOT_CONJ ?
      ] },                                                         #     )
      # comparison
      { mod: EXACTLY_ONE, sub_sequence: [                          #     | (
        { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },            #       POSSESSIVE ?
        { mod: EXACTLY_ONE, token: Token::SUBJECT },               #       SUBJECT
        { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },            #       POSSESSIVE ?
        { mod: EXACTLY_ONE, branch_sequence: [                     #       (
          { mod: EXACTLY_ONE, sub_sequence: [                      #         (
            { mod: EXACTLY_ONE, branch_sequence: [                 #           (
              { mod: EXACTLY_ONE, token: Token::COMP_1 },          #             COMP_1
              { mod: EXACTLY_ONE, sub_sequence: [                  #             | (
                { mod: EXACTLY_ONE, token: Token::COMP_1_TO },     #               COMP_1_TO
                { mod: EXACTLY_ONE, token: Token::COMP_1_EQ },     #               COMP_1_EQ
              ] },                                                 #             )
              { mod: EXACTLY_ONE, token: Token::COMP_1_GTEQ },     #             | COMP_1_GTEQ
              { mod: EXACTLY_ONE, token: Token::COMP_1_LTEQ },     #             | COMP_1_LTEQ
              { mod: EXACTLY_ONE, token: Token::COMP_1_EMP },      #             | COMP_1_EMP
            ] },                                                   #           )
            { mod: EXACTLY_ONE, branch_sequence: [                 #           (
              { mod: EXACTLY_ONE, token: Token::COMP_2_CONJ },     #             COMP_2
              { mod: EXACTLY_ONE, token: Token::COMP_2_NOT_CONJ }, #             | COMP_2
            ] },                                                   #           )
          ] },                                                     #         )
          { mod: EXACTLY_ONE, sub_sequence: [                      #         | (
            { mod: EXACTLY_ONE, token: Token::COMP_1_YORI },       #           COMP_1_YORI
            { mod: EXACTLY_ONE, branch_sequence: [                 #           (
              { mod: EXACTLY_ONE, token: Token::COMP_2_LT_CONJ },  #             COMP_2_LT_CONJ
              { mod: EXACTLY_ONE, token: Token::COMP_2_GT_CONJ },  #             | COMP_2_GT_CONJ
            ] },                                                   #           )
          ] },                                                     #         )
          { mod: EXACTLY_ONE, sub_sequence: [                      #         | (
            { mod: EXACTLY_ONE, token: Token::COMP_1_IN },         #           COMP_1_IN
            { mod: EXACTLY_ONE, branch_sequence: [                 #           (
              { mod: EXACTLY_ONE, token: Token::COMP_2_BE_CONJ },  #             COMP_2_BE_CONJ
              { mod: EXACTLY_ONE, token: Token::COMP_2_NBE_CONJ }, #             | COMP_NBE_CONJ
            ] },                                                   #           )
          ] },                                                     #         )
        ] },                                                       #       )
      ] },                                                         #     )
    ] },                                                           #   )
    { mod: EXACTLY_ONE, token: Token::COMMA },                     #   COMMA
    { mod: EXACTLY_ONE, branch_sequence: [                         #   (
      { mod: EXACTLY_ONE, token: Token::AND },                     #     AND
      { mod: EXACTLY_ONE, token: Token::OR },                      #     | OR
    ] },                                                           #   )
  ] }.freeze                                                       # ) *

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
      { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },       # POSSESSIVE ?
      { mod: EXACTLY_ONE, token: Token::TOPIC },            # TOPIC
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
      { mod: ZERO_OR_ONE, branch_sequence: [                   # (
        { mod: EXACTLY_ONE, sub_sequence: [                    #   (
          { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },      #     POSSESSIVE ?
          { mod: EXACTLY_ONE, token: Token::PARAMETER },       #     PARAMETER
          { mod: EXACTLY_ONE, branch_sequence: [               #     (
            { mod: EXACTLY_ONE, sub_sequence: [                #       (
              { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },  #         POSSESSIVE ?
              { mod: EXACTLY_ONE, token: Token::PARAMETER },   #         PARAMETER
            ] },                                               #       )
            { mod: EXACTLY_ONE, token: Token::LOOP_ITERATOR }, #       | LOOP_ITERATOR
          ] },                                                 #     )
        ] },                                                   #   )
        { mod: EXACTLY_ONE, token: Token::NUM_TIMES },         #   | NUM_TIMES
      ] },                                                     # ) ?
      { mod: EXACTLY_ONE, token: Token::LOOP },                # LOOP
      { mod: EXACTLY_ONE, token: Token::EOL },                 # EOL
    ],

    'While Loop' => [
      MULTI_CONDITION_SEQUENCE,                                     # ( ... ) *
      { mod: EXACTLY_ONE, branch_sequence: [                        # (
        # truthy check
        { mod: EXACTLY_ONE, sub_sequence: [                         #   (
          { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },           #     POSSESSIVE ?
          { mod: EXACTLY_ONE, token: Token::COMP_1 },               #     COMP_1
          { mod: EXACTLY_ONE, token: Token::QUESTION },             #     QUESTION
          { mod: EXACTLY_ONE, branch_sequence: [                    #     (
            { mod: EXACTLY_ONE, token: Token::COMP_2_TRUE_MOD },    #       COMP_2_TRUE_MOD
            { mod: EXACTLY_ONE, token: Token::COMP_2_FALSE_MOD },   #       | COMP_2_FALSE_MOD
          ] },                                                      #     )
        ] },                                                        #   )
        # function call
        { mod: EXACTLY_ONE, sub_sequence: [                         #   | (
          { mod: ZERO_OR_MORE, sub_sequence: [                      #     (
            { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },         #      POSSESSIVE ?
            { mod: EXACTLY_ONE, token: Token::PARAMETER },          #      PARAMETER
          ] },                                                      #     ) *
          { mod: EXACTLY_ONE, token: Token::FUNCTION_CALL },        #     FUNCTION_CALL
          { mod: ZERO_OR_ONE, token: Token::BANG },                 #     BANG ?
          { mod: ZERO_OR_ONE, token: Token::QUESTION },             #     QUESTION ?
          { mod: ZERO_OR_ONE, token: Token::COMP_2_NOT_MOD },       #     COMP_2_NOT_MOD ?
        ] },                                                        #   )
        # comparison
        { mod: EXACTLY_ONE, sub_sequence: [                         #   | (
          { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },           #     POSSESSIVE ?
          { mod: EXACTLY_ONE, token: Token::SUBJECT },              #     SUBJECT
          { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },           #     POSSESSIVE ?
          { mod: EXACTLY_ONE, branch_sequence: [                    #     (
            { mod: EXACTLY_ONE, sub_sequence: [                     #       (
              { mod: EXACTLY_ONE, branch_sequence: [                #         (
                { mod: EXACTLY_ONE, token: Token::COMP_1 },         #           COMP_1
                { mod: EXACTLY_ONE, sub_sequence: [                 #           | (
                  { mod: EXACTLY_ONE, token: Token::COMP_1_TO },    #             COMP_1_TO
                  { mod: EXACTLY_ONE, token: Token::COMP_1_EQ },    #             COMP_1_EQ
                ] },                                                #           )
                { mod: EXACTLY_ONE, token: Token::COMP_1_GTEQ },    #           | COMP_1_GTEQ
                { mod: EXACTLY_ONE, token: Token::COMP_1_LTEQ },    #           | COMP_1_LTEQ
                { mod: EXACTLY_ONE, token: Token::COMP_1_EMP },     #           | COMP_1_EMP
              ] },                                                  #         )
              { mod: EXACTLY_ONE, branch_sequence: [                #         (
                { mod: EXACTLY_ONE, token: Token::COMP_2_MOD },     #           COMP_2_MOD
                { mod: EXACTLY_ONE, token: Token::COMP_2_NOT_MOD }, #           | COMP_2_NOT_MOD
              ] },                                                  #         )
            ] },                                                    #       )
            { mod: EXACTLY_ONE, sub_sequence: [                     #       | (
              { mod: EXACTLY_ONE, token: Token::COMP_1_YORI },      #         COMP_1_YORI
              { mod: EXACTLY_ONE, branch_sequence: [                #         (
                { mod: EXACTLY_ONE, token: Token::COMP_2_LT_MOD },  #           COMP_2_LT_MOD
                { mod: EXACTLY_ONE, token: Token::COMP_2_GT_MOD },  #           | COMP_2_GT_MOD
              ] },                                                  #         )
            ] },                                                    #       )
            { mod: EXACTLY_ONE, sub_sequence: [                     #       | (
              { mod: EXACTLY_ONE, token: Token::COMP_1_IN },        #         COMP_1_IN
              { mod: EXACTLY_ONE, branch_sequence: [                #         (
                { mod: EXACTLY_ONE, token: Token::COMP_2_BE_MOD },  #           COMP_2_BE_MOD
                { mod: EXACTLY_ONE, token: Token::COMP_2_NBE_MOD }, #           | COMP_NBE_MOD
              ] },                                                  #         )
            ] },                                                    #       )
          ] },                                                      #     )
        ] },                                                        #   )
      ] },                                                          # )
      { mod: EXACTLY_ONE, token: Token::WHILE },                    # WHILE
      { mod: EXACTLY_ONE, token: Token::LOOP },                     # LOOP
      { mod: EXACTLY_ONE, token: Token::EOL },                      # EOL
    ],

    'If Conditional' => [
      { mod: EXACTLY_ONE, branch_sequence: [                     # (
        { mod: EXACTLY_ONE, token: Token::IF },                  #   IF
        { mod: EXACTLY_ONE, token: Token::ELSE_IF },             #   | ELSE_IF
      ] },                                                       # )
      MULTI_CONDITION_SEQUENCE,                                  # ( ... ) *
      { mod: EXACTLY_ONE, branch_sequence: [                     # (
        # truthy check
        { mod: EXACTLY_ONE, sub_sequence: [                      #   (
          { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },        #     POSSESSIVE ?
          { mod: EXACTLY_ONE, token: Token::COMP_1 },            #     COMP_1
          { mod: EXACTLY_ONE, token: Token::QUESTION },          #     QUESTION
          { mod: EXACTLY_ONE, branch_sequence: [                 #     (
            { mod: EXACTLY_ONE, token: Token::COMP_2 },          #       COMP_2
            { mod: EXACTLY_ONE, token: Token::COMP_2_NOT },      #       | COMP_2_NOT
          ] },                                                   #     )
        ] },                                                     #   )
        # function call
        { mod: EXACTLY_ONE, sub_sequence: [                      #   | (
          { mod: ZERO_OR_MORE, sub_sequence: [                   #     (
            { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },      #      POSSESSIVE ?
            { mod: EXACTLY_ONE, token: Token::PARAMETER },       #      PARAMETER
          ] },                                                   #     ) *
          { mod: EXACTLY_ONE, token: Token::FUNCTION_CALL },     #     FUNCTION_CALL
          { mod: ZERO_OR_ONE, token: Token::BANG },              #     BANG ?
          { mod: ZERO_OR_ONE, token: Token::QUESTION },          #     QUESTION ?
          { mod: EXACTLY_ONE, branch_sequence: [                 #     (
            { mod: EXACTLY_ONE, token: Token::COMP_2 },          #       COMP_2
            { mod: EXACTLY_ONE, token: Token::COMP_2_NOT },      #       | COMP_2_NOT
          ] },                                                   #     )
        ] },                                                     #   )
        # comparison
        { mod: EXACTLY_ONE, sub_sequence: [                      #   | (
          { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },        #     POSSESSIVE ?
          { mod: EXACTLY_ONE, token: Token::SUBJECT },           #     SUBJECT
          { mod: ZERO_OR_ONE, token: Token::POSSESSIVE },        #     POSSESSIVE ?
          { mod: EXACTLY_ONE, branch_sequence: [                 #     (
            { mod: EXACTLY_ONE, sub_sequence: [                  #       (
              { mod: EXACTLY_ONE, branch_sequence: [             #         (
                { mod: EXACTLY_ONE, token: Token::COMP_1 },      #           COMP_1
                { mod: EXACTLY_ONE, sub_sequence: [              #           | (
                  { mod: EXACTLY_ONE, token: Token::COMP_1_TO }, #             COMP_1_TO
                  { mod: EXACTLY_ONE, token: Token::COMP_1_EQ }, #             COMP_1_EQ
                ] },                                             #           )
                { mod: EXACTLY_ONE, token: Token::COMP_1_GTEQ }, #           | COMP_1_GTEQ
                { mod: EXACTLY_ONE, token: Token::COMP_1_LTEQ }, #           | COMP_1_LTEQ
                { mod: EXACTLY_ONE, token: Token::COMP_1_EMP },  #           | COMP_1_EMP
              ] },                                               #         )
              { mod: EXACTLY_ONE, branch_sequence: [             #         (
                { mod: EXACTLY_ONE, token: Token::COMP_2 },      #           COMP_2
                { mod: EXACTLY_ONE, token: Token::COMP_2_NOT },  #           | COMP_2_NOT
              ] },                                               #         )
            ] },                                                 #       )
            { mod: EXACTLY_ONE, sub_sequence: [                  #       | (
              { mod: EXACTLY_ONE, token: Token::COMP_1_YORI },   #         COMP_1_YORI
              { mod: EXACTLY_ONE, branch_sequence: [             #         (
                { mod: EXACTLY_ONE, token: Token::COMP_2_LT },   #           COMP_2_LT
                { mod: EXACTLY_ONE, token: Token::COMP_2_GT },   #           | COMP_2_GT
              ] },                                               #         )
            ] },                                                 #       )
            { mod: EXACTLY_ONE, sub_sequence: [                  #       | (
              { mod: EXACTLY_ONE, token: Token::COMP_1_IN },     #         COMP_1_IN
              { mod: EXACTLY_ONE, branch_sequence: [             #         (
                { mod: EXACTLY_ONE, token: Token::COMP_2_BE },   #           COMP_2_BE
                { mod: EXACTLY_ONE, token: Token::COMP_2_NBE },  #           | COMP_NBE
              ] },                                               #         )
            ] },                                                 #       )
          ] },                                                   #     )
        ] },                                                     #   )
      ] },                                                       # )
      { mod: EXACTLY_ONE, token: Token::EOL },                   # EOL
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
