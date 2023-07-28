const s:Vital = vital#colorcolumn#new()
const s:TOML = s:Vital.import('Text.TOML')

function colorcolumn#setup(opts) abort
  const s:opts = a:opts

  augroup colorcolumn
    autocmd!
  augroup END

  for ft in s:opts->keys()
    exec 'autocmd' 'colorcolumn' 'FileType' ft 'call' 's:set_cc("<amatch>"->expand())'
  endfor
endfunction

let s:memo = {}

function s:get_cc(dir, fname_pattern, value_path) abort
  if a:dir ==# '/'
    return v:null
  endif

  if s:memo->has_key(a:dir)
    return s:memo[a:dir]
  endif

  const files = a:dir->readdir({ fname -> fname =~# a:fname_pattern })
  if files->len() ==# 0
    const cc = s:get_cc(a:dir->fnamemodify(':h'), a:fname_pattern, a:value_path)
    let s:memo[a:dir] = cc
    return cc
  endif

  const file = [a:dir, files[0]]->join('/')
  const ext = file->fnamemodify(':e')
  if ext ==# 'toml'
    const dict = s:TOML.parse_file(file)
  elseif ext =~# '^\%(json\|jsonc\)$'
    const dict = file->readfile()->join()->json_decode()
  elseif ext =~# 'ya\{,1}ml'
    const dict = denops#request('colorcolumn', 'parseYaml', [file])
  else
    throw 'colorcolumn: Not supported filetype: ' .. ext
  endif
  try
    const cc = a:value_path(dict)
    let s:memo[a:dir] = cc
    return cc
  catch /E716/
    " Key not present in dictionay.
    return v:null
  endtry
endfunction

function s:set_cc(ft) abort
  const opts = s:opts[a:ft]
  const fname_pattern = opts->get('fname_pattern', v:null)
  const GetValue = opts->get('value_path', v:null)
  if fname_pattern is v:null
    throw 'colorcolumn: fname_pattern is not provided in ' .. a:ft .. ' config.'
  endif
  if GetValue is v:null
    throw 'colorcolumn: value_path is not provided in ' .. a:ft .. ' config.'
  endif

  let dir = bufname()->fnamemodify(':p:h')
  if !dir->isdirectory()
    return
  endif

  const cc = s:get_cc(dir, fname_pattern, GetValue)
  if cc isnot v:null
    let &l:colorcolumn = cc
  endif
endfunction
