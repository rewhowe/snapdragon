" Vim syntax file
" Language: Snapdragon
" Maintainer: Rew Howe
" Latest Revision: 2020-10-02

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

" If and ElseIf are covered by IfBlockRegion
" syn keyword CompKeyword
"       \ もし
"       \ もしくは
"       \ または
"       \ それ以外
"       \ ちがえば
"       \ 違えば

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

let number = '-?(\d+\.\d+|\d+)'
let eol    = whitespaceRegion . '*(' . commentStartRegion . '.*)?$'

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
exe 'syn match SpecialKeyword /\v^' . whitespaceRegion . '*' . specialGroup . '(は)@=/'

" bol or separator, number, followed by a question, comma, whitespace, or a comment
exe 'syn match NumberMatch /\v' .
      \ '(^|' . separatorRegion . ')@<=' .
      \ number .
      \ '(' .
      \   questionRegion .
      \   '|' . commaRegion .
      \   '|' . whitespaceRegion . '+' .
      \   '|' . eol .
      \ ')@=' .
      \ '/'

exe 'syn match CommentMatch /\v' . commentStartRegion . '.*$/ contains=TodoKeyword'

" syn match CompParamMatch /\v[^ 　]{-}((が|\?|？|と|より|以上|以下)([ 　][ 　]{-})@=)@=/ contained
" TODO: make sure built-ins stay coloured
" exe 'syn match CompParamMatch /\v' .
"       \ notWhitespaceRegion . '{-}' .
"       \ '(' .
"       \   comp12Group .
"       \   '(' . whitespaceRegion . ')@=' .
"       \ ')@=' .
"       \ '/' .
"       \ ' contained'
exe 'syn match IfElseIfMatch /\v' .
      \ '(^|' . whitespaceRegion . ')' .
      \ ifElseIfGroup .
      \ '(' . whitespaceRegion . ')@=' .
      \ '/ contained'
exe 'syn match ElseMatch /\v(^|' . whitespaceRegion . ')' . elseGroup . '(' . eol . ')@=/'
"syn match Comp12Match /\v([^ 　]{-})@<=(が|\?|？|と|より|以上|以下)([ 　][ 　]{-})@=/ contained
exe 'syn match Comp12Match /\v(' . notWhitespaceRegion . '{-})@<=' . comp12Group . '(' . whitespaceRegion . '*)@=/ contained'
exe 'syn match Comp3Match /\v(' . whitespaceRegion . ')@<=' . comp3Group . '(' . eol . ')@=/ contained'
"syn match CompFuncCallParamMatch /\v(が[ 　])@<![^ 　]{-}((から|まで|で|と|に|へ|を)([ 　][ 　]{-})@=)@=/ contained

exe 'syn match CompSpecialMatch /\v(' . whitespaceRegion . ')@<=' . specialGroup . '(' . comp12Group . ')@=/'
exe 'syn match CompBoolMatch /\v(' . whitespaceRegion . ')@<=' . boolGroup . '(' . comp12Group . ')@=/'
exe 'syn match CompNullMatch /\v(' . whitespaceRegion . ')@<=' . nullGroup . '(' . comp12Group . ')@=/'
exe 'syn match CompArrayMatch /\v(' . whitespaceRegion . ')@<=' . arrayGroup . '(' . comp12Group . ')@=/'

syn match VarDefMatch /\v(^[ 　]*[^ ,　、]+)@<=は([ 　])@=/

syn match FuncDefMatch /\v^.*[^ ,　、]+とは/
        \ contains=FuncDefLeadingWhitespaceMatch,FuncDefParamMatch,FuncDefParticleMatch,FuncDefNameMatch

syn match FuncDefLeadingWhitespaceMatch /\v^[ 　]*/
        \ contained nextgroup=FuncDefParamMatch
syn match FuncDefParamMatch /\v([ 　]*)@<=[^ ,　、][^ ,　、]{-}((から|まで|で|と|に|へ|を)[ 　])@=/
        \ contained
" non whitespace, particle (not preceding は), followed by whitespace
syn match FuncDefParticleMatch /\v([^ 　])@<=(から|まで|で|と|に|へ|を)(は$)@!([ 　][ 　]{-})@=/
        \ contained
" zero or more whitespace, a name, followed by とは and zero or more whitespace
" syn match FuncDefNameMatch /\v([ 　]*)@<=[^ ,　、]+(とは[ 　]*((\(|（).*)?$)@=/
syn match FuncDefNameMatch /\v([ 　]*)@<=[^ ,　、]+(とは[ 　]*([(（].*)?$)@=/
        \ contained

" TODO: rename to be more generic
" non whitespace, particle, followed by whitespace
syn match FuncCallParticleMatch /\v([^ 　])@<=(から|まで|で|と|に|へ|を)[ 　]@=/
syn match FuncCallGlobalSpecialMatch /\v(それ|あれ)((から|まで|で|と|に|へ|を)[ 　])@=/
" syn match NumberMatch /\v(^|[ 　])-?(\d+\.\d+|\d+)((から|まで|で|と|に|へ|を)[ 　]|[?？])@=/
syn match FuncCallNumberMatch /\v-?(\d+\.\d+|\d+)((から|まで|で|と|に|へ|を)[ 　])@=/
" syn match BoolNullMatch /\v(^|[ 　])(真|肯定|はい|正|偽|否定|いいえ|無|無い|無し|ヌル)([?？])@=/
syn match FuncCallBoolMatch /\v(真|肯定|はい|正|偽|否定|いいえ)((から|まで|で|と|に|へ|を)[ 　])@=/
syn match FuncCallNullMatch /\v(無|無い|無し|ヌル)((から|まで|で|と|に|へ|を)[ 　])@=/

" a name, followed by a space and というものは
"syn match ClassDefMatch /^\v[^ ,　、]*[ 　]+と(い|言)う(もの|物)は/
"        \ contains=ClassDefLeadingWhitespaceMatch
"
"syn match ClassDefLeadingWhitespaceMatch /\v^[ 　]*/
"        \ contained nextgroup=ClassDefNameMatch
"syn match ClassDefNameMatch /\v([ 　]*)@<=[^ ,　、]+([ 　]+と(い|言)う(もの|物)は)@=/
"        \ contained

syn match StringInterpolationMatch /\v(【)@<=.+(】)@=/
        \ contained
syn match NewlineMatch /\v(\\)@<!(\\n|￥ｎ)/
        \ contained

"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
syn region IfBlockRegion start=/\v^[ 　]*(もし|もしくは|または)[ 　]+/
                       \ end=/\v[ 　]+(ならば|でなければ|(等し(くな)?|ひとし(くな)?|小さ|ちいさ|短|みじか|低|ひく|少な|すくな|大き|おおき|長|なが|高|たか|多|おお)ければ)[ 　]*$/
         \ keepend oneline skipwhite
         \ contains=CompParamMatch,CompParticleMatch,CompFuncCallParamMatch,FuncCallParticleMatch,NumberMatch,BoolNullMatch,StringRegion
syn region StringRegion start=/「/ end=/\v(\\)@<!」/
         \ contains=StringInterpolationRegion,NewlineMatch
syn region StringInterpolationRegion start=/\v(\\)@<!【/ end=/】/
         \ keepend contained
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
hi GlobalSpecialKeyword                  ctermfg=208
hi NoOpKeyword                           ctermfg=208
hi BoolKeyword           cterm=bold      ctermfg=208
hi NullKeyword           cterm=bold      ctermfg=208
hi TodoKeyword           cterm=bold      ctermfg=146
hi CompElseKeyword                       ctermfg=067

hi LoopIteratorKeyword                   ctermfg=109
hi LoopKeyword                           ctermfg=067
hi LoopNextKeyword                       ctermfg=067
hi LoopBreakKeyword                      ctermfg=067

hi ReturnKeyword                         ctermfg=067

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
hi BoolNullMatch                         ctermfg=208
hi NumberMatch                           ctermfg=203

hi CompParamMatch                        ctermfg=140
hi CompParticleMatch                     ctermfg=109
hi CompFuncCallParamMatch                ctermfg=255
hi CommentMatch                          ctermfg=243

hi VarDefMatch                           ctermfg=109

hi FuncDefMatch          cterm=underline ctermfg=109
hi FuncDefNameMatch      cterm=underline ctermfg=222
hi FuncDefParamMatch     cterm=underline ctermfg=140
hi FuncDefParticleMatch  cterm=underline ctermfg=109

hi FuncCallParticleMatch                 ctermfg=109
hi FuncCallGlobalSpecialMatch            ctermfg=208
hi FuncCallNumberMatch                   ctermfg=203
hi FuncCallBoolMatch     cterm=bold      ctermfg=208
hi FuncCallNullMatch     cterm=bold      ctermfg=208

hi ClassDefMatch         cterm=underline ctermfg=109
hi ClassDefNameMatch     cterm=underline ctermfg=214

hi StringInterpolationMatch              ctermfg=255
hi NewlineMatch                          ctermfg=109

"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
hi IfBlockRegion                         ctermfg=067
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
