" Vim syntax file
" Language: Snapdragon
" Maintainer: Rew Howe
" Latest Revision: 2020-10-09

if exists("b:current_syntax")
  finish
endif

" TODO: A lot of the regex can be broken by adjacent block comments. This
" should be fixed later.
" TODO: Syntax should also support full-width numbers.

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

syn keyword ReturnKeyword かえす
syn keyword ReturnKeyword 返す
syn keyword ReturnKeyword なる
syn keyword ReturnKeyword もどる
syn keyword ReturnKeyword 戻る
syn keyword ReturnKeyword かえる
syn keyword ReturnKeyword 返る

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
let comp3Group    = '(ならば|でなければ|(等し(くな)?|ひとし(くな)?|小さ|ちいさ|短|みじか|低|ひく|少な|すくな|大き|おおき|長|なが|高|たか|多|おお)ければ)'

let whitespaceRegion    = '[ 　]'
let notWhitespaceRegion = '[^ 　]'
let commaRegion         = '[,、]'
let separatorRegion     = '[ ,　、]'
let notSeparatorRegion  = '[^ ,　、]'
let commentStartRegion  = '[(（]'
let questionRegion      = '[?？]'
let bangRegion          = '[!！]' " NOTE: Unused
let punctuationRegion   = '[?？!！]'

let number = '-?(\d+\.\d+|\d+)'
let bol    = '^' . whitespaceRegion . '*'
let eol    = whitespaceRegion . '*(' . commentStartRegion . '.*)?$'

let builtInGroup = '%(' .
      \ '[言い]%(う|っ[てた])' .
      \ '|%(ログ|表示|追加|連結)%(する|し%(て|た))' .
      \ '|%([足た]|%(先頭を)?%([抜ぬ]き出|[抜ぬ]きだ))%(す|し[てた])' .
      \ '|%([引ひ]|%(全部)?[抜ぬ])%(く|い[てた])' .
      \ '|%(先頭から)?%(押し込|おしこ)(む|ん[でだ])' .
      \ '|([投な]げ|[掛か]け)[るてた]' .
      \ '|[割わ]%(る|っ[てた])' .
      \ '|割った余りを求め[るてた]' .
      \ '|わった%(余|あま)りを求め[るてた]' .
      \ '|わったあまりを%(求|もと)め[るてた]' .
      \ ')'

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
exe 'syn match SpecialKeyword /\v^' . whitespaceRegion . '*' . specialGroup . '(は)@=/'

exe 'syn match VarDefMatch /\v(' . bol . notSeparatorRegion . '+)@<=は(' . whitespaceRegion . ')@=/'

exe 'syn match NumberMatch /\v' .
      \ '(^|' . separatorRegion . ')@<=' .
      \ number .
      \ '(' . questionRegion . '|' . commaRegion . '|' . whitespaceRegion . '+|' . eol . ')@=' .
      \ '/'

exe 'syn match CommentMatch /\v' . commentStartRegion . '.*$/ contains=TodoKeyword'
exe 'syn match PunctuationMatch /\v'.
      \ '(' . notSeparatorRegion . '+)@<=' .
      \ punctuationRegion . '+' .
      \ '(' . whitespaceRegion . '|' . eol . ')@=' .
      \ '/'

exe 'syn match IfElseIfMatch /\v' .
      \ '(' . bol . ')' .
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
      \ '(' . whitespaceRegion . '*)@=' .
      \ '/' .
      \ ' contained'
exe 'syn match Comp3Match /\v' .
      \ '(' . whitespaceRegion . ')@<=' .
      \ comp3Group .
      \ '(' . eol . ')@=' .
      \ '/' .
      \ ' contained'

exe 'syn match CompSpecialMatch /\v(' . whitespaceRegion . ')@<=' . specialGroup . '(' . comp12Group . ')@=/'
exe 'syn match CompNumberMatch /\v(' . whitespaceRegion . ')@<=' . number . '(' . comp12Group . ')@=/'
exe 'syn match CompBoolMatch /\v(' . whitespaceRegion . ')@<=' . boolGroup . '(' . comp12Group . ')@=/'
exe 'syn match CompNullMatch /\v(' . whitespaceRegion . ')@<=' . nullGroup . '(' . comp12Group . ')@=/'
exe 'syn match CompArrayMatch /\v(' . whitespaceRegion . ')@<=' . arrayGroup . '(' . comp12Group . ')@=/'

exe 'syn match FuncDefMatch /\v^.*' . notSeparatorRegion . '+とは/' .
      \ ' contains=
      \ FuncDefLeadingWhitespaceMatch,
      \ FuncDefParamMatch,
      \ FuncDefParticleMatch,
      \ FuncDefNameMatch
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

exe 'syn match ParamParticleMatch /\v('. notWhitespaceRegion . ')@<=' . particleGroup . whitespaceRegion . '@=/'
exe 'syn match ParamSpecialMatch /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ specialGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match ParamNumberMatch /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ number .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match ParamBoolMatch /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ boolGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match ParamNullMatch /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ nullGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'
exe 'syn match ParamArrayMatch /\v' .
      \ '(^|' . whitespaceRegion . ')@<=' .
      \ arrayGroup .
      \ '(' . particleGroup . whitespaceRegion . ')@=' .
      \ '/'

exe 'syn match BuiltInMatch /\v' .
      \ '(' . bol . '|' . whitespaceRegion . ')' .
      \ builtInGroup .
      \ '(' . whitespaceRegion . '*' . punctuationRegion . '*' . eol . ')@=' .
      \ '/'

syn match StringInterpolationMatch /\v(【)@<=.+(】)@=/
        \ contained
syn match NewlineMatch /\v(\\)@<!(\\n|￥ｎ)/
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
      \ NumberMatch,
      \ PunctuationMatch,
      \ ParamParticleMatch,
      \ ParamSpecialMatch,ParamNumberMatch,ParamBoolMatch,ParamNullMatch,ParamArrayMatch,
      \ CompSpecialMatch,CompNumberMatch,CompBoolMatch,CompNullMatch,CompArrayMatch,
      \ CommentRegion,CommentMatch
      \ '

syn region StringRegion start=/「/ end=/\v(\\)@<!」/
         \ contains=StringInterpolationRegion,NewlineMatch
syn region StringInterpolationRegion start=/\v(\\)@<!【/ end=/】/
         \ keepend
         \ contained
         \ contains=StringInterpolationMatch,NewlineMatch
syn region CommentRegion start=/※/ end=/※/

"-------------------------------------------------------------------------------
" Highlighting
"-------------------------------------------------------------------------------
" http://vimdoc.sourceforge.net/htmldoc/syntax.html#syntax
let b:current_syntax = 'sd'

"-------------------------------------------------------------------------------
" Keywords
"-------------------------------------------------------------------------------
hi SpecialKeyword        cterm=bold      ctermfg=208
hi NoOpKeyword                           ctermfg=208
hi BoolKeyword                           ctermfg=208
hi NullKeyword                           ctermfg=208
hi ArrayKeyword                          ctermfg=208
hi TodoKeyword           cterm=bold      ctermfg=146

hi LoopIteratorKeyword                   ctermfg=109
hi LoopKeyword                           ctermfg=067
hi LoopNextKeyword                       ctermfg=067
hi LoopBreakKeyword                      ctermfg=067

hi ReturnKeyword                         ctermfg=067

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
hi VarDefMatch                           ctermfg=109
hi NumberMatch                           ctermfg=203
hi CommentMatch                          ctermfg=243
hi PunctuationMatch                      ctermfg=109

hi IfElseIfMatch                         ctermfg=067
hi ElseMatch                             ctermfg=067
hi Comp12Match                           ctermfg=109
hi Comp3Match                            ctermfg=067

hi CompSpecialMatch      cterm=bold      ctermfg=208
hi CompNumberMatch                       ctermfg=203
hi CompBoolMatch                         ctermfg=208
hi CompNullMatch                         ctermfg=208
hi CompArrayMatch                        ctermfg=208

hi FuncDefMatch          cterm=underline ctermfg=109
hi FuncDefNameMatch      cterm=underline ctermfg=222
hi FuncDefParamMatch     cterm=underline ctermfg=140
hi FuncDefParticleMatch  cterm=underline ctermfg=109

hi ParamParticleMatch                    ctermfg=109
hi ParamSpecialMatch     cterm=bold      ctermfg=208
hi ParamNumberMatch                      ctermfg=203
hi ParamBoolMatch                        ctermfg=208
hi ParamNullMatch                        ctermfg=208
hi ParamArrayMatch                       ctermfg=208

hi StringInterpolationMatch              ctermfg=255
hi NewlineMatch                          ctermfg=109

hi BuiltInMatch                          ctermfg=222

"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
hi StringRegion                          ctermfg=064
hi StringInterpolationRegion             ctermfg=109
hi CommentRegion                         ctermfg=243

"-------------------------------------------------------------------------------
" Full-Width Space Display
"-------------------------------------------------------------------------------
" 全角スペースの表示を弄る
" http://code-life.net/?p=2704
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=reverse ctermfg=232 gui=bold guifg=#000000
endfunction

augroup ZenkakuSpace
autocmd!
autocmd ColorScheme       * call ZenkakuSpace()
autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
augroup END
call ZenkakuSpace()
