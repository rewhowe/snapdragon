au FileType sd set completefunc=CompleteSnapdragon

fun! CompleteSnapdragon(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while (start > 0 && line[start - 1] =~ '\S')
        \ && (start < 3 || line[start - 3 : start - 1] != '　')
      let start -= 1
    endwhile
    return start
  else
    " find keywords matching with "a:base"
    let matches = []
    let dict = readfile(glob('~/.vim/dict/sd.txt'))
    for m in dict
      if m =~ '^' .. a:base
        call add(matches, m)
      endif
    endfor
    return matches
  endif
endfun
