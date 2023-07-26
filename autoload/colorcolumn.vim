const s:Vital = vital#colorcolumn#new()
const s:TOML = s:Vital.import('Text.TOML')

function colorcolumn#setup() abort
  const s:opts = g:->get('colorcolumn_options', {})

  augroup colorcolumn
    autocmd!
  augroup END

  for ft in s:opts->keys()
    exec 'autocmd' 'colorcolumn' 'FileType' ft 'call' 's:detectcc("' .. ft .. '")'
  endfor
endfunction

function s:detectcc(ft) abort
  const opts = s:opts[a:ft]
  const fname_pattern = opts->get('fname_pattern', v:null)
  const GetValue = opts->get('value_path', v:null)
  if fname_pattern is v:null
    throw 'colorcolumn: fname_pattern is not provided in ' .. a:ft .. ' config.'
  endif
  if GetValue is v:null
    throw 'colorcolumn: value_path is not provided in ' .. a:ft .. ' config.'
  endif

  let dir = bufname()->fnamemodify(':h')
  while dir !=# '/'
    let files = dir->readdir({ fname -> fname =~# fname_pattern })
    if files->len() ==# 0
      let dir = dir->fnamemodify(':h')
      continue
    endif
    let file = [dir, files[0]]->join('/')
    break
  endwhile

  if !l:->has_key('file')
    return
  endif

  if file->fnamemodify(':e') ==# 'toml'
    const root = s:TOML.parse_file(file)
    const val = GetValue(root)
    let &l:colorcolumn = val
  endif
endfunction
