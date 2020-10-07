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
syn keyword GlobalSpecialKeyword それ
syn keyword GlobalSpecialKeyword あれ
syn keyword BoolKeyword 真
syn keyword BoolKeyword 正
syn keyword BoolKeyword 肯定
syn keyword BoolKeyword はい
syn keyword BoolKeyword 偽
syn keyword BoolKeyword 否定
syn keyword BoolKeyword いいえ
syn keyword NullKeyword 無
syn keyword NullKeyword 無い
syn keyword NullKeyword 無し
syn keyword NullKeyword ヌル
syn keyword TodoKeyword TODO メモ
syn keyword NoOpKeyword ・・・

syn keyword CompElseKeyword それ以外
syn keyword CompElseKeyword ちがえば
syn keyword CompElseKeyword 違えば

syn keyword LoopIteratorKeyword たいして
syn keyword LoopIteratorKeyword 対して
syn keyword LoopKeyword くりかえす
syn keyword LoopKeyword 繰りかえす
syn keyword LoopKeyword くり返す
syn keyword LoopKeyword 繰り返す
syn keyword LoopNextKeyword つぎ
syn keyword LoopNextKeyword 次
syn keyword LoopBreakKeyword おわり
syn keyword LoopBreakKeyword 終わり

syn keyword ReturnKeyword かえす
syn keyword ReturnKeyword 返す
syn keyword ReturnKeyword なる
syn keyword ReturnKeyword もどる
syn keyword ReturnKeyword 戻る
syn keyword ReturnKeyword かえる
syn keyword ReturnKeyword 返る

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
syn match GlobalSpecialKeyword /\v^[ 　]*((それ)|(あれ))(は)@=/

syn match BoolNullMatch /\v(^|[ 　]|[,、])@<=(真|肯定|はい|正|偽|否定|いいえ|無|無い|無し|ヌル)([,、]|[ 　]+|[ 　]*([(（].*)?$)@=/
" bol or whitespace, bool or null, followed by a comma, whitespace, or a comment
syn match BoolNullMatch /\v(^|[ 　])(真|肯定|はい|正|偽|否定|いいえ|無|無い|無し|ヌル)((から|まで|で|と|に|へ|を)[ 　]|[?？])@=/
" bol or whitespace, number, followed by a particle or question mark

syn match NumberMatch /\v(^|[ 　]|[,、])@<=-?(\d+\.\d+|\d+)([,、]|[ 　]+|[ 　]*([(（].*)?$)@=/
" bol or whitespace, number, followed by a comma, whitespace, or a comment
syn match NumberMatch /\v(^|[ 　])-?(\d+\.\d+|\d+)((から|まで|で|と|に|へ|を)[ 　]|[?？])@=/
" bol or whitespace, number, followed by a particle or question mark

syn match CommentMatch /\v[(（].*$/ contains=TodoKeyword

syn match CompParamMatch /\v[^ 　]{-}((が|\?|？|と|より|以上|以下)([ 　][ 　]{-})@=)@=/ contained
syn match CompParticleMatch /\v([^ 　]{-})@<=(が|\?|？|と|より|以上|以下)([ 　][ 　]{-})@=/ contained
syn match CompFuncCallParamMatch /\v(が[ 　])@<![^ 　]{-}((から|まで|で|と|に|へ|を)([ 　][ 　]{-})@=)@=/ contained

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
syn match FuncDefNameMatch /\v([ 　]*)@<=[^ ,　、]+(とは[ 　]*((\(|（).*)?$)@=/
        \ contained

" non whitespace, particle, followed by whitespace
syn match FuncCallParticleMatch /\v([^ 　])@<=(から|まで|で|と|に|へ|を)[ 　]@=/
syn match FuncCallGlobalSpecialMatch /\v(それ|あれ)((から|まで|で|と|に|へ|を)[ 　])@=/

" a name, followed by a space and というものは
syn match ClassDefMatch /^\v[^ ,　、]*[ 　]+と(い|言)う(もの|物)は/
        \ contains=ClassDefLeadingWhitespaceMatch

syn match ClassDefLeadingWhitespaceMatch /\v^[ 　]*/
        \ contained nextgroup=ClassDefNameMatch
syn match ClassDefNameMatch /\v([ 　]*)@<=[^ ,　、]+([ 　]+と(い|言)う(もの|物)は)@=/
        \ contained

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
         \ contains=CompParamMatch,CompParticleMatch,CompFuncCallParamMatch,FuncCallParticleMatch,NumberMatch,BoolNullMatch
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
