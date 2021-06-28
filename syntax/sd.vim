" Vim syntax file
" Language: Snapdragon
" Maintainer: Rew Howe
" Latest Revision: 2021-05-28

if exists("b:current_syntax")
  finish
endif

"-------------------------------------------------------------------------------
" Keywords
"-------------------------------------------------------------------------------
syn keyword SpecialKeyword
      \ それ
      \ あれ
      \ 引数列
" Bool
syn keyword ConstantKeyword
      \ 真
      \ 正
      \ 肯定
      \ はい
      \ 偽
      \ 否定
      \ いいえ
" Null
syn keyword ConstantKeyword
      \ 無
      \ 無い
      \ 無し
      \ ヌル
" Array
syn keyword ConstantKeyword
      \ 配列
      \ 連想配列

syn keyword NoOpKeyword
      \ ・・・
syn keyword DebugKeyword
      \ 蛾

"-------------------------------------------------------------------------------
" Variables
"-------------------------------------------------------------------------------
let specialGroup  = '(それ|あれ|引数列)'
let boolGroup     = '(真|肯定|はい|正|偽|否定|いいえ)'
let nullGroup     = '(無|無い|無し|ヌル)'
let arrayGroup    = '((連想)?配列)'
let particleGroup = '(から|まで|で|と|に|へ|を)'
let ifElseIfGroup = '(もし|もしくは|または)'
let elseGroup     = '(それ以外(ならば?|は|だと)|(違|ちが)(うならば?|えば)|(じゃ|で)なければ)'
let subComp1Group = '(が|と|より|以上|以下)'
let comp2Group    = '%(' .
      \ 'ならば?' .
      \ '|%(で|じゃ)?なければ' .
      \ '|%(' .
      \   '小さ|ちいさ' .
      \   '|短|みじか' .
      \   '|低|ひく' .
      \   '|少な|すくな' .
      \   '|大き|おおき' .
      \   '|長|なが' .
      \   '|高|たか' .
      \   '|多|おお' .
      \ ')ければ' .
      \ '|で?あれば' .
      \ ')'
" NOTE: Must match でなく before で
let comp2ConjGroup = '%(' .
      \ '%(で|じゃ)?なく' .
      \ '|で%(あり)?' .
      \ '|%(' .
      \   '小さ|ちいさ' .
      \   '|短|みじか' .
      \   '|低|ひく' .
      \   '|少な|すくな' .
      \   '|大き|おおき' .
      \   '|長|なが' .
      \   '|高|たか' .
      \   '|多|おお' .
      \ ')く' .
      \ '|あり' .
      \ ')'
let comp2AttrGroup = '%(' .
      \ 'で?ある' .
      \ '|%(で|じゃ)?ない' .
      \ '|%(' .
      \   '小さ|ちいさ' .
      \   '|短|みじか' .
      \   '|低|ひく' .
      \   '|少な|すくな' .
      \   '|大き|おおき' .
      \   '|長|なが' .
      \   '|高|たか' .
      \   '|多|おお' .
      \ ')い' .
      \ ')'
let compLangAuxGroup = '%(空|から|同じ|おなじ|中に|なかに)'
let compConjOpGroup  = '%(且つ|かつ|又は|または)'
let loopGroup        = '%(%(繰り%(返|かえ)|くり%(返|かえ))す)'
let loopIterGroup    = '%(%(対|たい)して)'
let whileGroup       = '%(限り|かぎり)'

let whitespaceRegion    = '[ \t　()（）]'
let notWhitespaceRegion = '[^ \t　]'
let commaRegion         = '[,、]'
let separatorRegion     = '[ \t,　、()（）]'
let notSeparatorRegion  = '[^ \t,　、※()（）]'
let questionRegion      = '[?？]'
let bangRegion          = '[!！]'
let punctuationRegion   = '[?？!！]'
let counterRegion       = '[つ人個件匹]'

let propertyGroup = '%(' .
      \ '%(長|なが|大き|おおき)さ' .
      \ '|%(人|個|件|匹|文字)数|かず' .
      \ '|キー列' .
      \ '|先頭%(以外)?' .
      \ '|末尾%(以外)?' .
      \ ')'
let indexedPropertyGroupAfterSpace = '%(' .
      \ '%(^|' . whitespaceRegion . '+)\d+' .
      \ ')@<=' .
      \ '%(つ|人|個|件|匹|文字)目'

let inlineCommentStart = '※'
let positiveNumber     = '([0-9０-９]+[.．][0-9０-９]+|[0-9０-９]+)'
let number             = '-?' . positiveNumber
let blockComment       = '[(（].*[)）]' . whitespaceRegion . '*'
let bol                = '^' . whitespaceRegion . '*%(' . blockComment . ')?'
let eol                = whitespaceRegion . '*%(' . inlineCommentStart . '.*)?%(' . blockComment . ')?$'

let linebreak       = whitespaceRegion . '*\\'
" Some amount of whitespace before something, or a linebreak.
let beforeSomething = '(' . whitespaceRegion . '+' . notSeparatorRegion . '|\\)@='
" After a BOL or space (differs from bol which must contain BOL).
let afterSpace      = '(^|' . whitespaceRegion . ')@<='

let builtInGroup = '%(' .
      \ '[言い]%(う|っ[てた])' .
      \ '|%(表示|追加|結合|数値化|整数化|連結|分割|記入)%(する|し%(て|た))' .
      \ '|%(ポイ捨|切り捨|きりす)て[るてた]' .
      \ '|%(全部)?[取と]%(る|っ[てた])' .
      \ '|%(繋|つな)%(ぐ|い[でだ])' .
      \ '|%(切り[上下]|きり[あさ])げ[るてた]' .
      \ '|%(並び替|ならびか)え[るてた]' .
      \ '|%([足た]|%(先頭を)?%(引き出|[引ひ]きだ)|探|さが)%(す|し[てた])' .
      \ '|%([引ひ]|%(全部)?[抜ぬ]|切り抜|[切き]りぬ)%(く|い[てた])' .
      \ '|%(先頭から)?%(押し込|おしこ)%(む|ん[でだ])' .
      \ '|%([投な]げ|[掛か]け)[るてた]' .
      \ '|[割わ]%(る|っ[てた])' .
      \ '|割った余りを求め[るてた]' .
      \ '|わった%(余|あま)りを求め[るてた]' .
      \ '|わったあまりを%(求|もと)め[るてた]' .
      \ '|乱数の種に%(与|あた)え[るてた]' .
      \ '|の乱数を発生させ[るてた]' .
      \ ')'

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
" Must be after space because of possible properties (not bol).
exe 'syn match SpecialKeyword /\v' . afterSpace . specialGroup . '(は)@=/'
exe 'syn match PropertyKeyword /\v' .
      \ afterSpace . propertyGroup .
      \ '(は|' . whitespaceRegion . '|' . eol . ')@=/'
exe 'syn match PropertyKeyword /\v' .
      \ indexedPropertyGroupAfterSpace .
      \ '(は|' . whitespaceRegion . '|' . eol . ')@=/'

exe 'syn match AssignmentMatch /\v' .
      \ '(' . whitespaceRegion . '*' . notSeparatorRegion . '+)@<=は' .
      \ beforeSomething .
      \ '/'

exe 'syn match NumberMatch /\v' .
      \ '(^|' . separatorRegion . ')@<=' .
      \ number .
      \ '/'

exe 'syn match PunctuationMatch /\v'.
      \ punctuationRegion . '+' .
      \ '(' . commaRegion . '|' . whitespaceRegion . '|' . linebreak . '|' . eol . ')@=' .
      \ '/'

"---------------------------------------
" Comparison Matches
"---------------------------------------
" ELSE
exe 'syn match LangMainKeyword /\v(' . bol . ')@<=' . elseGroup . '(' . eol . ')@=/'

exe 'syn match SubComp1Match /\v' .
      \ '(' . notWhitespaceRegion . notWhitespaceRegion . '{-})@<=' .
      \ subComp1Group .
      \ beforeSomething .
      \ '/'

exe 'syn match Comp2Match /\v' .
      \ afterSpace .
      \ comp2Group .
      \ '(' . eol . ')@=' .
      \ '/' .
      \ ' contained'
exe 'syn match Comp2ConjMatch /\v' .
      \ afterSpace .
      \ comp2ConjGroup .
      \ '(' . whitespaceRegion . '*' . commaRegion. '|' . linebreak . ')@=' .
      \ '/'
exe 'syn match CompConjOpMatch /\v' .
      \ '(^|' . whitespaceRegion . '|' . commaRegion . ')@<=' .
      \ compConjOpGroup .
      \ beforeSomething .
      \ '/'
exe 'syn match CompLangAuxMatch /\v' . afterSpace . compLangAuxGroup . beforeSomething . '/'

let beforeSubComp1AndSomething = '(' .
      \ subComp1Group . '(' . whitespaceRegion . '+' . notSeparatorRegion . '|' . linebreak . ')' .
      \ ')@='
exe 'syn match SpecialKeyword  /\v' . afterSpace . specialGroup  . beforeSubComp1AndSomething . '/'
exe 'syn match ConstantKeyword /\v' . afterSpace . boolGroup     . beforeSubComp1AndSomething . '/'
exe 'syn match ConstantKeyword /\v' . afterSpace . nullGroup     . beforeSubComp1AndSomething . '/'
exe 'syn match ConstantKeyword /\v' . afterSpace . arrayGroup    . beforeSubComp1AndSomething . '/'
exe 'syn match PropertyKeyword /\v' . afterSpace . propertyGroup . beforeSubComp1AndSomething . '/'
exe 'syn match PropertyKeyword /\v' . indexedPropertyGroupAfterSpace . beforeSubComp1AndSomething . '/'

"---------------------------------------
" Looping Matches
"---------------------------------------
" LOOP
exe 'syn match LangMainKeyword /\v' . afterSpace . loopGroup . '(' . eol . ')@=/'
" NEXT and BREAK
exe 'syn match LangMainKeyword /\v' .
      \ '(' . bol . ')@<=' .
      \ '(次|つぎ|終わり|おわり)' .
      \ '(' . eol . ')@=' .
      \ '/'

" Comp2ConjMatch etc covered by Comparison Matches (above).
exe 'syn match Comp2AttrMatch /\v' .
      \ afterSpace .
      \ comp2AttrGroup .
      \ '(' . whitespaceRegion . '+' . whileGroup . '|' . linebreak . ')@=' .
      \ '/'

let beforeLoop = '(' . whitespaceRegion . '+' . loopGroup . '|' . linebreak . ')@='
" LOOP ITERATOR
exe 'syn match LangAuxKeyword /\v' . afterSpace . loopIterGroup . beforeLoop . '/'
" WHILE
exe 'syn match LangAuxKeyword /\v' . afterSpace . whileGroup . beforeLoop . '/'
" NUM TIMES
exe 'syn match LangAuxKeyword /\v(' . bol . positiveNumber . ')@<=回' . beforeLoop . '/'

"---------------------------------------
" Function Def Matches
"---------------------------------------
exe 'syn match FuncDefMatch /\v^.*' . notSeparatorRegion . '+とは' . bangRegion . '?'  . eol . '/' .
      \ ' contains=
      \ FuncDefLeadingWhitespaceMatch,
      \ FuncDefParamMatch,
      \ FuncDefParticleMatch,
      \ FuncDefNameMatch,
      \ CommentMatch
      \ '

exe 'syn match FuncDefLeadingWhitespaceMatch /\v' . bol . '/' .
      \ ' nextgroup=FuncDefParamMatch' .
      \ ' contained'
exe 'syn match FuncDefParamMatch /\v' .
      \ '(' . whitespaceRegion . '*)@<=' .
      \ notSeparatorRegion . notSeparatorRegion . '{-}' .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/' .
      \ ' contained'
exe 'syn match FuncDefParticleMatch /\v' .
      \ '(' . notWhitespaceRegion . ')@<=' .
      \ particleGroup . '(は$)@!' .
      \ '(' . whitespaceRegion . ')@=' .
      \ '/' .
      \ ' contained'
exe 'syn match FuncDefNameMatch /\v' .
      \ '(' . whitespaceRegion . '*)@<=' .
      \ notSeparatorRegion . '+' .
      \ '(とは' . whitespaceRegion . '*' . bangRegion . '?' . eol . ')@=' .
      \ '/' .
      \ ' contained'

"---------------------------------------
" Parameter Matches
"---------------------------------------
exe 'syn match ParamParticleMatch /\v' .
      \ '(' . notSeparatorRegion . ')@<=' .
      \ particleGroup .
      \ beforeSomething .
      \ '/'
let beforeParticleAndSomething = '(' .
      \ particleGroup . '(' . whitespaceRegion . '+' . notSeparatorRegion . '|' . linebreak . ')' .
      \ ')@='
exe 'syn match SpecialKeyword /\v' . afterSpace . specialGroup . beforeParticleAndSomething . '/'
exe 'syn match ConstantKeyword /\v' . afterSpace . boolGroup . beforeParticleAndSomething . '/'
exe 'syn match ConstantKeyword /\v' . afterSpace . nullGroup . beforeParticleAndSomething . '/'
exe 'syn match ConstantKeyword /\v' . afterSpace . arrayGroup . beforeParticleAndSomething . '/'
exe 'syn match PropertyKeyword /\v' . afterSpace . propertyGroup . beforeParticleAndSomething . '/'
exe 'syn match PropertyKeyword /\v' . indexedPropertyGroupAfterSpace . beforeParticleAndSomething . '/'

"---------------------------------------
" Possessive Matches
"---------------------------------------
exe 'syn match PossessiveParticleMatch /\v' .
      \ '(' . notSeparatorRegion . ')@<=' .
      \ 'の' .
      \ beforeSomething .
      \ '/'
exe 'syn match SpecialKeyword /\v' .
      \ '(^|' . whitespaceRegion . '|' . commaRegion . ')@<=' .
      \ specialGroup .
      \ '(の' . '(' . whitespaceRegion . '+' . notSeparatorRegion . '|' . linebreak . ')' . ')@=' .
      \ '/'

"---------------------------------------
" Misc
"---------------------------------------
" RETURN (optional parameter)
exe 'syn match LangMainKeyword /\v' .
      \ afterSpace .
      \ '(返す|かえす|なる)' .
      \ '(' . eol . ')@=' .
      \ '/'
" RETURN (no parameter)
exe 'syn match LangMainKeyword /\v' .
      \ '(' . bol . ')@<=' .
      \ '(返|かえ|戻|もど)る' .
      \ '(' . eol . ')@=' .
      \ '/'

exe 'syn match BuiltInMatch /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ builtInGroup .
      \ '(' . whitespaceRegion . '|' . punctuationRegion . '|' . commaRegion . '|' . eol . '|\\)@=' .
      \ '/'

exe 'syn match StringInterpSpecialKeyword /\v(【)@<=' . specialGroup . '(の' . whitespaceRegion . ')@=/'
syn match StringInterpolationMatch /\v(【)@<=.{-}(】)@=/
        \ contained
        \ contains=
        \ StringInterpSpecialKeyword,
        \ PossessiveParticleMatch,
        \ SpecialKeyword,
        \ PropertyKeyword,
        \ StringRegion
syn match StringSpecialCharMatch /\v([^\\]\\(\\\\)*)@<!(\\n|￥ｎ)/
        \ contained
" Escapes need to be doubled due to string resolution + string format
syn match StringSpecialCharMatch /\v([^\\]\\\\?(\\\\\\\\)*)@<!〇/
        \ contained

"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
let notAfterPrevLineComma = '(' . commaRegion . '(' . eol . ')?\n)@<!'
exe 'syn region IfBlockRegion' .
      \ ' matchgroup=IfElseIfMatch' .
      \ ' start=/\v' .
      \ notAfterPrevLineComma .
      \ '(' . bol . ')@<=' .
      \ ifElseIfGroup .
      \ '(' . whitespaceRegion . '|\\)@=' .
      \ '/'
      \ ' end=/\v(^|' . whitespaceRegion. ')@<=' . comp2Group . '(' . eol . ')@=/' .
      \ ' keepend' .
      \ ' contains=
      \ SubComp1Match,
      \ Comp2Match,
      \ Comp2ConjMatch,
      \ CompConjOpMatch,
      \ CompLangAuxMatch,
      \ StringRegion,
      \ PunctuationMatch,
      \ BuiltInMatch,
      \ NumberMatch,
      \ SpecialKeyword,ConstantKeyword,PropertyKeyword,
      \ LogicalOperatorKeyword,
      \ ParamParticleMatch,PossessiveParticleMatch,
      \ CommentRegion,CommentMatch
      \ '

syn region StringRegion start=/「/ end=/\v([^\\]\\(\\\\)*)@<!」/
         \ contains=StringInterpolationRegion,StringSpecialCharMatch
syn region StringInterpolationRegion start=/\v([^\\]\\(\\\\)*)@<!【/ end=/】/
         \ keepend
         \ contained
         \ contains=StringInterpolationMatch,StringSpecialCharMatch

"-------------------------------------------------------------------------------
" Comments (separated for highest precendennce)
"-------------------------------------------------------------------------------
syn region CommentRegion start=/\v\(|（/ end=/\v\)|）/ contains=TodoKeyword
exe 'syn match CommentMatch /\v' . inlineCommentStart . '.*$/ contains=TodoKeyword'

exe 'syn match TodoKeyword /\v(TODO|メモ)(' . separatorRegion . '|' . eol . ')@=/ contained'

"-------------------------------------------------------------------------------
" Highlighting
"-------------------------------------------------------------------------------
" http://vimdoc.sourceforge.net/htmldoc/syntax.html#syntax
let b:current_syntax = 'sd'

"-------------------------------------------------------------------------------
" Keywords
"-------------------------------------------------------------------------------
hi SpecialKeyword             cterm=bold ctermfg=208
hi StringInterpSpecialKeyword cterm=bold ctermfg=208
hi ConstantKeyword                       ctermfg=208

hi TodoKeyword                cterm=bold ctermfg=146
hi NoOpKeyword                           ctermfg=208
hi DebugKeyword                          ctermfg=222

hi LangMainKeyword                       ctermfg=067
hi LangAuxKeyword                        ctermfg=109

hi PropertyKeyword                       ctermfg=222

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
hi AssignmentMatch                       ctermfg=109
hi NumberMatch                           ctermfg=203
hi PunctuationMatch                      ctermfg=109
hi CommentMatch                          ctermfg=243

hi IfElseIfMatch                         ctermfg=067
hi SubComp1Match                         ctermfg=109
hi Comp2Match                            ctermfg=067
hi Comp2ConjMatch                        ctermfg=067
hi Comp2AttrMatch                        ctermfg=067
hi CompLangAuxMatch                      ctermfg=109
hi CompConjOpMatch                       ctermfg=140

hi FuncDefMatch          cterm=underline ctermfg=109
hi FuncDefNameMatch      cterm=underline ctermfg=222
hi FuncDefParamMatch     cterm=underline ctermfg=140
hi FuncDefParticleMatch  cterm=underline ctermfg=109

hi ParamParticleMatch                    ctermfg=109
hi PossessiveParticleMatch               ctermfg=109

hi StringInterpolationMatch              ctermfg=255
hi StringSpecialCharMatch                ctermfg=109

hi BuiltInMatch                          ctermfg=222

"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
hi StringRegion                          ctermfg=064
hi StringInterpolationRegion             ctermfg=109
hi CommentRegion                         ctermfg=243
