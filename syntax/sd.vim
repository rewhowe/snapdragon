" Vim syntax file
" Language: Snapdragon
" Maintainer: Rew Howe
" Latest Revision: 2021-03-15

if exists("b:current_syntax")
  finish
endif

"-------------------------------------------------------------------------------
" Keywords
"-------------------------------------------------------------------------------
syn keyword SpecialKeyword
      \ それ
      \ あれ
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

syn keyword TodoKeyword
      \ TODO
      \ メモ
syn keyword NoOpKeyword
      \ ・・・
syn keyword DebugKeyword
      \ 蛾

"---------------------------------------
" Main Keywords
"---------------------------------------
" Loop
syn keyword LangMainKeyword
      \ 繰り返す
      \ 繰りかえす
      \ くり返す
      \ くりかえす
" Loop Next
syn keyword LangMainKeyword
      \ 次
      \ つぎ
" Loop Break
syn keyword LangMainKeyword
      \ 終わり
      \ おわり
" Return
syn keyword LangMainKeyword
      \ かえす
      \ 返す
      \ なる
      \ もどる
      \ 戻る
      \ かえる
      \ 返る

"---------------------------------------
" Auxiliary Keywords
"---------------------------------------
" Loop Iterator
syn keyword LangAuxKeyword
      \ 対して
      \ たいして

syn keyword PropertyKeyword
      \ 長さ
      \ ながさ
      \ 大きさ
      \ おおきさ
      \ 数
      \ かず
      \ 人数
      \ 個数
      \ 件数
      \ 匹数
      \ 文字数

"-------------------------------------------------------------------------------
" Variables
"-------------------------------------------------------------------------------
let specialGroup  = '(それ|あれ)'
let boolGroup     = '(真|肯定|はい|正|偽|否定|いいえ)'
let nullGroup     = '(無|無い|無し|ヌル)'
let arrayGroup    = '((連想)?配列)'
let particleGroup = '(から|まで|で|と|に|へ|を)'
let ifElseIfGroup = '(もし|もしくは|または)'
let elseGroup     = '(それ以外(ならば?|は|だと)|(違|ちが)(うならば?|えば)|(じゃ|で)なければ)'
let subComp1Group = '(が|\?|？|と|より|以上|以下)'
let comp2Group    = '%(' .
      \ 'ならば?' .
      \ '|%(で|じゃ)なければ' .
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
let propertyGroup = '((長|なが|大き|おおき)さ|(人|個|件|匹|文字)数|かず)'

let whitespaceRegion    = '[ \t　()（）]'
let notWhitespaceRegion = '[^ \t　]'
let commaRegion         = '[,、]'
let separatorRegion     = '[ \t,　、()（）]'
let notSeparatorRegion  = '[^ \t,　、]'
let questionRegion      = '[?？]'
let bangRegion          = '[!！]'
let punctuationRegion   = '[?？!！]'
let counterRegion       = '[つ人個件匹]'

let inlineCommentStart = '※'
let number = '-?([0-9０-９]+[.．][0-9０-９]+|[0-9０-９]+)'
let bol    = '^' . whitespaceRegion . '*'
let eol    = whitespaceRegion . '*(' . inlineCommentStart . '.*)?$'

let builtInGroup = '%(' .
      \ '[言い]%(う|っ[てた])' .
      \ '|%(表示|追加|結合)%(する|し%(て|た))' .
      \ '|ポイ捨て[るてた]' .
      \ '|%(繋|つな)%(ぐ|い[でだ])' .
      \ '|[取と]%(る|っ[てた])' .
      \ '|%([足た]|%(先頭を)?%(引き出|[引ひ]きだ))%(す|し[てた])' .
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
exe 'syn match SpecialKeyword /\v' . whitespaceRegion . '*' . specialGroup . '(は)@=/'

exe 'syn match AssignmentMatch /\v' .
      \ '(' . whitespaceRegion . '*' . notSeparatorRegion . '+)@<=は' .
      \ '(' . whitespaceRegion . ')@=' .
      \ '/'

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
      \ '(' . whitespaceRegion . '|' . eol . ')@=' .
      \ '/' .
      \ ' contained'
exe 'syn match ElseMatch /\v' .
      \ '(' . bol . ')@<=' .
      \ elseGroup .
      \ '(' . eol . ')@=' .
      \ '/'
exe 'syn match SubComp1Match /\v' .
      \ '(' . notWhitespaceRegion . '{-})@<=' .
      \ subComp1Group .
      \ '(' . whitespaceRegion . '+)@=' .
      \ '/' .
      \ ' contained'
exe 'syn match Comp2Match /\v' .
      \ '(' . whitespaceRegion . ')@<=' .
      \ comp2Group .
      \ '(' . eol . ')@=' .
      \ '/' .
      \ ' contained'

exe 'syn match SpecialKeyword  /\v(' . whitespaceRegion . ')@<=' . specialGroup  . '(' . subComp1Group . ')@=/ contained'
exe 'syn match ConstantKeyword /\v(' . whitespaceRegion . ')@<=' . boolGroup     . '(' . subComp1Group . ')@=/ contained'
exe 'syn match ConstantKeyword /\v(' . whitespaceRegion . ')@<=' . nullGroup     . '(' . subComp1Group . ')@=/ contained'
exe 'syn match ConstantKeyword /\v(' . whitespaceRegion . ')@<=' . arrayGroup    . '(' . subComp1Group . ')@=/ contained'
exe 'syn match PropertyKeyword /\v(' . whitespaceRegion . ')@<=' . propertyGroup . '(' . subComp1Group . ')@=/ contained'

" Standalone comparison close
exe 'syn match Comp2Match /\v' .
      \ '(' . bol . '|' . whitespaceRegion . ')@<=' .
      \ comp2Group .
      \ '(' . whitespaceRegion . '|' . eol . ')@=' .
      \ '/'

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
exe 'syn match ConstantKeyword /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ boolGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match ConstantKeyword /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ nullGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match ConstantKeyword /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ arrayGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match PropertyKeyword /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ propertyGroup .
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
      \   whitespaceRegion . '*' . punctuationRegion . '*(' . whitespaceRegion . '*' . comp2Group . ')?' . eol .
      \ ')@=' .
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
syn match NewlineMatch /\v([^\\]\\(\\\\)*)@<!(\\n|￥ｎ)/
        \ contained

"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
exe 'syn region IfBlockRegion' .
      \ ' start=/\v' . bol . ifElseIfGroup . '(' . whitespaceRegion . '|' . eol . ')/'
      \ ' end=/\v' . whitespaceRegion . comp2Group . eol . '/' .
      \ ' keepend' .
      \ ' skipwhite' .
      \ ' contains=
      \ IfElseIfMatch,
      \ SubComp1Match,
      \ Comp2Match,
      \ StringRegion,
      \ PunctuationMatch,
      \ NumberMatch,
      \ SpecialKeyword,ConstantKeyword,PropertyKeyword,
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
syn region CommentRegion start=/\v\(|（/ end=/\v\)|）/
exe 'syn match CommentMatch /\v' . inlineCommentStart . '.*$/ contains=TodoKeyword'

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
hi ElseMatch                             ctermfg=067
hi SubComp1Match                         ctermfg=109
hi Comp2Match                            ctermfg=067

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
