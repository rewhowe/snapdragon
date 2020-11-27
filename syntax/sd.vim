" Vim syntax file
" Language: Snapdragon
" Maintainer: Rew Howe
" Latest Revision: 2020-11-02

if exists("b:current_syntax")
  finish
endif

"-------------------------------------------------------------------------------
" Keywords
"-------------------------------------------------------------------------------
syn keyword SpecialKeyword
      \ それ
      \ あれ
syn keyword BoolKeyword
      \ 真
      \ 正
      \ 肯定
      \ はい
      \ 偽
      \ 否定
      \ いいえ
syn keyword NullKeyword
      \ 無
      \ 無い
      \ 無し
      \ ヌル
syn keyword ArrayKeyword
      \ 配列
syn keyword TodoKeyword
      \ TODO
      \ メモ
syn keyword NoOpKeyword
      \ ・・・
syn keyword DebugKeyword
      \ 蛾

syn keyword LoopIteratorKeyword
      \ 対して
      \ たいして
syn keyword LoopKeyword
      \ 繰り返す
      \ 繰りかえす
      \ くり返す
      \ くりかえす
syn keyword LoopNextKeyword
      \ 次
      \ つぎ
syn keyword LoopBreakKeyword
      \ 終わり
      \ おわり

syn keyword ReturnKeyword
      \ かえす
      \ 返す
      \ なる
      \ もどる
      \ 戻る
      \ かえる
      \ 返る

syn keyword AttrKeyword
      \ 長さ
      \ ながさ
      \ 大きさ
      \ おおきさ
      \ 数
      \ かず

"-------------------------------------------------------------------------------
" Variables
"-------------------------------------------------------------------------------
let specialGroup  = '(それ|あれ)'
let boolGroup     = '(真|肯定|はい|正|偽|否定|いいえ)'
let nullGroup     = '(無|無い|無し|ヌル)'
let arrayGroup    = '(配列)' " TODO: (v1.1.0) add 連想配列
let particleGroup = '(から|まで|で|と|に|へ|を)'
let ifElseIfGroup = '(もし|もしくは|または)'
let elseGroup     = '(それ以外|違えば|ちがえば)'
let comp12Group   = '(が|\?|？|と|より|以上|以下)'
let comp3Group    = '%(' .
      \ 'ならば?' .
      \ '|でなければ' .
      \ '|%(' .
      \   '等し%(くな)?|ひとし%(くな)?' .
      \   '|小さ|ちいさ' .
      \   '|短|みじか' .
      \   '|低|ひく' .
      \   '|少な|すくな' .
      \   '|大き|おおき' .
      \   '|長|なが' .
      \   '|高|たか' .
      \   '|多|おお' .
      \ ')ければ)'
let attrGroup     = '((長|なが|大き|おおき)さ|数|かず)'

let whitespaceRegion    = '[ \t　※]'
let notWhitespaceRegion = '[^ \t　]'
let commaRegion         = '[,、]'
let separatorRegion     = '[ \t,　、※]'
let notSeparatorRegion  = '[^ \t,　、]'
let commentStartRegion  = '[(（]'
let questionRegion      = '[?？]'
let bangRegion          = '[!！]'
let punctuationRegion   = '[?？!！]'
let counterRegion       = '[つ人個件匹]'

let number = '-?([0-9０-９]+[.．][0-9０-９]+|[0-9０-９]+)'
let bol    = '^' . whitespaceRegion . '*'
let eol    = whitespaceRegion . '*(' . commentStartRegion . '.*)?$'

let builtInGroup = '%(' .
      \ '[言い]%(う|っ[てた])' .
      \ '|%(表示|追加|連結)%(する|し%(て|た))' .
      \ '|ポイ捨て[るてた]' .
      \ '|%([足た]|%(先頭を)?%([抜ぬ]き出|[抜ぬ]きだ))%(す|し[てた])' .
      \ '|%([引ひ]|%(全部)?[抜ぬ])%(く|い[てた])' .
      \ '|%(先頭から)?%(押し込|おしこ)(む|ん[でだ])' .
      \ '|%([投な]げ|[掛か]け)[るてた]' .
      \ '|[割わ]%(る|っ[てた])' .
      \ '|割った余りを求め[るてた]' .
      \ '|わった%(余|あま)りを求め[るてた]' .
      \ '|わったあまりを%(求|もと)め[るてた]' .
      \ ')'

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
exe 'syn match SpecialKeyword /\v^' . whitespaceRegion . '*' . specialGroup . '(は)@=/'

exe 'syn match AssignmentMatch /\v(' . bol . notSeparatorRegion . '+)@<=は(' . whitespaceRegion . ')@=/'

exe 'syn match NumberMatch /\v' .
      \ '(^|' . separatorRegion . ')@<=' .
      \ number .
      \ '/'

exe 'syn match PunctuationMatch /\v'.
      \ '(' . notSeparatorRegion . '+)@<=' .
      \ punctuationRegion . '+' .
      \ '(' . commaRegion . '|' . whitespaceRegion . '|' . eol . ')@=' .
      \ '/'

"---------------------------------------
" Comparison Matches
"---------------------------------------
exe 'syn match IfElseIfMatch /\v' .
      \ '(' . bol . ')@<=' .
      \ ifElseIfGroup .
      \ '(' . whitespaceRegion . ')@=' .
      \ '/' .
      \ ' contained'
exe 'syn match ElseMatch /\v' .
      \ '(' . bol . ')' .
      \ elseGroup .
      \ '(' . eol . ')@=' .
      \ '/'
exe 'syn match Comp12Match /\v' .
      \ '(' . notWhitespaceRegion . '{-})@<=' .
      \ comp12Group .
      \ '(' . whitespaceRegion . '+)@=' .
      \ '/' .
      \ ' contained'
exe 'syn match Comp3Match /\v' .
      \ '(' . whitespaceRegion . ')@<=' .
      \ comp3Group .
      \ '(' . eol . ')@=' .
      \ '/' .
      \ ' contained'

exe 'syn match SpecialKeyword /\v(' . whitespaceRegion . ')@<=' . specialGroup . '(' . comp12Group . ')@=/'
exe 'syn match BoolKeyword    /\v(' . whitespaceRegion . ')@<=' . boolGroup    . '(' . comp12Group . ')@=/'
exe 'syn match NullKeyword    /\v(' . whitespaceRegion . ')@<=' . nullGroup    . '(' . comp12Group . ')@=/'
exe 'syn match ArrayKeyword   /\v(' . whitespaceRegion . ')@<=' . arrayGroup   . '(' . comp12Group . ')@=/'
exe 'syn match AttrKeyword    /\v(' . whitespaceRegion . ')@<=' . attrGroup    . '(' . comp12Group . ')@=/'

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
exe 'syn match ParamParticleMatch /\v(' . notWhitespaceRegion . ')@<=' . particleGroup . whitespaceRegion . '@=/'
exe 'syn match SpecialKeyword /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ specialGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match BoolKeyword /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ boolGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match NullKeyword /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ nullGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match ArrayKeyword /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ arrayGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match AttrKeyword /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ attrGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'

"---------------------------------------
" Possessive Matches
"---------------------------------------
exe 'syn match PossessiveParticleMatch /\v' .
      \ '(' . notWhitespaceRegion . ')@<=' .
      \ 'の' .
      \ '(' . whitespaceRegion . ')@=' .
      \ '(' . eol . ')@!' .
      \ '/'
exe 'syn match SpecialKeyword /\v' .
      \ '(^|' . whitespaceRegion . '|' . commaRegion . ')@<=' .
      \ specialGroup .
      \ '(の' . whitespaceRegion . ')@=' .
      \ '/'

"---------------------------------------
" Misc
"---------------------------------------
exe 'syn match BuiltInMatch /\v' .
      \ '(' . bol . '|' . whitespaceRegion . ')@<=' .
      \ builtInGroup .
      \ '(' .
      \   whitespaceRegion . '*' . punctuationRegion . '*(' . whitespaceRegion . '*' . comp3Group . ')?' . eol .
      \ ')@=' .
      \ '/'

syn match StringInterpolationMatch /\v(【)@<=.+(】)@=/
        \ contained
syn match NewlineMatch /\v([^\\]\\(\\\\)*)@<!(\\n|￥ｎ)/
        \ contained

"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
exe 'syn region IfBlockRegion' .
      \ ' start=/\v' . bol . ifElseIfGroup . whitespaceRegion . '+/' .
      \ ' end=/\v' . whitespaceRegion . '+' . comp3Group . eol . '/' .
      \ ' keepend' .
      \ ' oneline' .
      \ ' skipwhite' .
      \ ' contains=
      \ IfElseIfMatch,
      \ Comp12Match,
      \ Comp3Match,
      \ StringRegion,
      \ PunctuationMatch,
      \ NumberMatch,
      \ SpecialKeyword,BoolKeyword,NullKeyword,ArrayKeyword,AttrKeyword,
      \ ParamParticleMatch,PossessiveParticleMatch,
      \ BuiltInMatch,
      \ CommentRegion,CommentMatch
      \ '

syn region StringRegion start=/「/ end=/\v([^\\]\\(\\\\)*)@<!」/
         \ contains=StringInterpolationRegion,NewlineMatch
syn region StringInterpolationRegion start=/\v([^\\]\\(\\\\)*)@<!【/ end=/】/
         \ keepend
         \ contained
         \ contains=StringInterpolationMatch,NewlineMatch

"-------------------------------------------------------------------------------
" Comments (separated for highest precendennce)
"-------------------------------------------------------------------------------
syn region CommentRegion start=/※/ end=/※/
exe 'syn match CommentMatch /\v' . commentStartRegion . '.*$/ contains=TodoKeyword'

"-------------------------------------------------------------------------------
" Highlighting
"-------------------------------------------------------------------------------
" http://vimdoc.sourceforge.net/htmldoc/syntax.html#syntax
let b:current_syntax = 'sd'

"-------------------------------------------------------------------------------
" Keywords
"-------------------------------------------------------------------------------
hi SpecialKeyword        cterm=bold      ctermfg=208
hi BoolKeyword                           ctermfg=208
hi NullKeyword                           ctermfg=208
hi ArrayKeyword                          ctermfg=208
hi TodoKeyword           cterm=bold      ctermfg=146
hi NoOpKeyword                           ctermfg=208
hi DebugKeyword                          ctermfg=222

hi LoopIteratorKeyword                   ctermfg=109
hi LoopKeyword                           ctermfg=067
hi LoopNextKeyword                       ctermfg=067
hi LoopBreakKeyword                      ctermfg=067

hi ReturnKeyword                         ctermfg=067
hi AttrKeyword                           ctermfg=222

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
hi AssignmentMatch                       ctermfg=109
hi NumberMatch                           ctermfg=203
hi PunctuationMatch                      ctermfg=109
hi CommentMatch                          ctermfg=243

hi IfElseIfMatch                         ctermfg=067
hi ElseMatch                             ctermfg=067
hi Comp12Match                           ctermfg=109
hi Comp3Match                            ctermfg=067

hi FuncDefMatch          cterm=underline ctermfg=109
hi FuncDefNameMatch      cterm=underline ctermfg=222
hi FuncDefParamMatch     cterm=underline ctermfg=140
hi FuncDefParticleMatch  cterm=underline ctermfg=109

hi ParamParticleMatch                    ctermfg=109
hi PossessiveParticleMatch               ctermfg=109

hi StringInterpolationMatch              ctermfg=255
hi NewlineMatch                          ctermfg=109

hi BuiltInMatch                          ctermfg=222

"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
hi StringRegion                          ctermfg=064
hi StringInterpolationRegion             ctermfg=109
hi CommentRegion                         ctermfg=243
