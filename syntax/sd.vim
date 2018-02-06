" Vim syntax file
" Language: Snapdragon
" Maintainer: Rew Howe
" Latest Revision: 2017-06-06

if exists("b:current_syntax")
  finish
endif

" Keywords
syn keyword GlobalSoreKeyword それ
syn keyword TodoKeyword TODO メモ
syn keyword NoOpKeyword ・・・

" Matches
syn match NumberMatch /\v[ ,　、]-?(\d+\.\d+|\d+)([ ,　、]+|[ ,　、]*$)@=/
syn match NumberMatch /\vは@<=-?(\d+\.\d+|\d+)[ ,　、]*$/

syn match ComparatorMatch /\v[^ ,　、]*[ ,　、]*(が)@=/ contained
syn match ComparatorMatch /\v(が)@<=[ ,　、]*[^ ,　、]*/ contained
syn match CommentMatch /\v(\(|（).*$/ contains=TodoKeyword

syn match FuncDefMatch /\v^.*[^ ,　、]+[ ,　、]+とは/
        \ contains=FuncDefLeadingWhitespaceMatch,FuncDefParamMatch,FuncDefParticleMatch,FuncDefNameMatch

syn match FuncDefLeadingWhitespaceMatch /\v^[ ,　、]*/
        \ contained nextgroup=FuncDefParamMatch
syn match FuncDefParamMatch /\v([ ,　、]*)@<=[^ ,　、][^ ,　、]{-}([ ,　、]*(から|まで|で|と|に|へ|を)[ ,　、])@=/
        \ contained
syn match FuncDefParticleMatch /\v(から|まで|で|と|に|へ|を)(は$)@!([ ,　、][ ,　、]{-})@=/
        \ contained
syn match FuncDefNameMatch /\v([ ,　、]*)@<=[^ ,　、]+([ ,　、]+とは[ ,　、]*$)@=/
        \ contained

syn match FuncCallParticleMatch /\v(から|まで|で|と|に|へ|を)[ ,　、]@=/

syn match ClassDefMatch /^\v.*[ ,　、]+と(い|言)う(もの|物)は/
        \ contains=ClassDefLeadingWhitespaceMatch

syn match ClassDefLeadingWhitespaceMatch /\v^[ ,　、]*/
        \ contained nextgroup=ClassDefNameMatch
syn match ClassDefNameMatch /\v([ ,　、]*)@<=[^ ,　、]+([ ,　、]+と(い|言)う(もの|物)は)@=/
        \ contained


" Regions
syn region IfBlockRegion start=/\v^[ ,　、]*もし[ ,　、]+/
                       \ end=/\v[ ,　、]+ならば[ ,　、]*$/
         \ keepend oneline contains=ComparatorMatch skipwhite
syn region StringRegion start=/「/ end=/[^\\]」/
         \ oneline

" Highlighting
" http://vimdoc.sourceforge.net/htmldoc/syntax.html#syntax
let b:current_syntax = 'sd'

" Keywords
hi GlobalSoreKeyword                     ctermfg=208
hi NoOpKeyword                           ctermfg=208
hi TodoKeyword           cterm=bold      ctermfg=146

" Matches
hi NumberMatch                           ctermfg=196

hi ComparatorMatch                       ctermfg=140
hi CommentMatch                          ctermfg=243

hi FuncDefMatch          cterm=underline ctermfg=067
hi FuncDefNameMatch      cterm=underline ctermfg=222
hi FuncDefParamMatch     cterm=underline ctermfg=135
hi FuncDefParticleMatch  cterm=underline ctermfg=153

hi FuncCallParticleMatch                 ctermfg=153

hi ClassDefMatch         cterm=underline ctermfg=067
hi ClassDefNameMatch     cterm=underline ctermfg=214
" TODO: use the same purple for func params, for class variables

" Regions
hi IfBlockRegion                         ctermfg=067
hi StringRegion                          ctermfg=064

" 全角スペースの表示を弄る
" http://code-life.net/?p=2704
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=reverse ctermfg=016 gui=bold guifg=#080808
endfunction

augroup ZenkakuSpace
autocmd!
autocmd ColorScheme       * call ZenkakuSpace()
autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
augroup END
call ZenkakuSpace()
