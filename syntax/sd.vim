" Vim syntax file
" Language: Snapdragon
" Maintainer: Rew Howe
" Latest Revision: 2018-08-20

if exists("b:current_syntax")
  finish
endif

"-------------------------------------------------------------------------------
" Keywords
"-------------------------------------------------------------------------------
syn keyword GlobalSpecialKeyword それ
syn keyword GlobalSpecialKeyword あれ
syn keyword TrueKeyword はい
syn keyword TrueKeyword 肯定
syn keyword FalseKeyword いいえ
syn keyword FalseKeyword 否定
syn keyword TodoKeyword TODO メモ
syn keyword NoOpKeyword ・・・

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
syn match NumberMatch /\v(^|[ 　]|[,、])@<=-?(\d+\.\d+|\d+)([,、]|[ 　]+|[ 　]*((\(|（).*)?$)@=/
" bol or whitespace, number, followed by a particle and whitespace
syn match NumberMatch /\v(^|[ 　])-?(\d+\.\d+|\d+)((から|まで|で|と|に|へ|を)[ 　])@=/

syn match ComparatorMatch /\v[^ ,　、]*[ 　]*(が)@=/ contained
syn match ComparatorMatch /\v(が)@<=[ 　]*[^ ,　、]*/ contained
syn match CommentMatch /\v(\(|（).*$/ contains=TodoKeyword

syn match VarDefMatch /\v(^[ 　]*[^ ,　、]+)@<=は([ 　])@=/

syn match FuncDefMatch /\v^.*[^ ,　、]+とは/
        \ contains=FuncDefLeadingWhitespaceMatch,FuncDefParamMatch,FuncDefParticleMatch,FuncDefNameMatch

syn match FuncDefLeadingWhitespaceMatch /\v^[ 　]*/
        \ contained nextgroup=FuncDefParamMatch
syn match FuncDefParamMatch /\v([ 　]*)@<=[^ ,　、][^ ,　、]{-}([ 　]*(から|まで|で|と|に|へ|を)[ 　])@=/
        \ contained
" particle (not preceding は), followed by whitespace
syn match FuncDefParticleMatch /\v(から|まで|で|と|に|へ|を)(は$)@!([ 　][ 　]{-})@=/
        \ contained
" zero or more whitespace, a name, followed by とは and zero or more whitespace
syn match FuncDefNameMatch /\v([ 　]*)@<=[^ ,　、]+(とは[ 　]*((\(|（).*)?$)@=/
        \ contained

" particle, followed by whitespace
syn match FuncCallParticleMatch /\v(から|まで|で|と|に|へ|を)[ 　]@=/

" a name, followed by a space and というものは
syn match ClassDefMatch /^\v[^ ,　、]*[ 　]+と(い|言)う(もの|物)は/
        \ contains=ClassDefLeadingWhitespaceMatch

syn match ClassDefLeadingWhitespaceMatch /\v^[ 　]*/
        \ contained nextgroup=ClassDefNameMatch
syn match ClassDefNameMatch /\v([ 　]*)@<=[^ ,　、]+([ 　]+と(い|言)う(もの|物)は)@=/
        \ contained


"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
syn region IfBlockRegion start=/\v^[ 　]*もし[ 　]+/
                       \ end=/\v[ 　]+ならば[ 　]*$/
         \ keepend oneline contains=ComparatorMatch skipwhite
syn region StringRegion start=/「/ end=/[^\\]」/
         \ oneline

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
hi TrueKeyword           cterm=bold      ctermfg=208
hi FalseKeyword          cterm=bold      ctermfg=208
hi TodoKeyword           cterm=bold      ctermfg=146

"-------------------------------------------------------------------------------
" Matches
"-------------------------------------------------------------------------------
hi NumberMatch                           ctermfg=203

hi ComparatorMatch                       ctermfg=140
hi CommentMatch                          ctermfg=243

hi VarDefMatch                           ctermfg=109

hi FuncDefMatch          cterm=underline ctermfg=109
hi FuncDefNameMatch      cterm=underline ctermfg=222
hi FuncDefParamMatch     cterm=underline ctermfg=140
hi FuncDefParticleMatch  cterm=underline ctermfg=109

hi FuncCallParticleMatch                 ctermfg=109

hi ClassDefMatch         cterm=underline ctermfg=109
hi ClassDefNameMatch     cterm=underline ctermfg=214
" TODO: use the same purple for func params, for class variables

"-------------------------------------------------------------------------------
" Regions
"-------------------------------------------------------------------------------
hi IfBlockRegion                         ctermfg=067
hi StringRegion                          ctermfg=064

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
