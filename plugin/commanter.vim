vim9script
# commanter - comment, uncomment or toggle lines and ranges.
# Install: plugin/commanter.vim (e.g. ~/vimfiles/plugin on Windows).
#
# Defaults:   <leader>c        comment   (normal: [count] lines, visual: range)
#             <leader><space>  uncomment (normal: [count] lines, visual: range)
#             <leader>,        toggle    (normal: [count] lines, visual: range)
# Commands:   :[range]Comment  :[range]Uncomment  :[range]CommentToggle
#
# Settings (set before the plugin loads):
#   g:commanter_map_comment    = '<leader>c'       ('' disables)
#   g:commanter_map_uncomment  = '<leader><space>' ('' disables)
#   g:commanter_map_toggle     = '<leader>,'       ('' disables; '<C-,>' works in gVim only)
#   g:commanter_markers        = {python: '# %s', html: '<!-- %s -->'}
#                                   per-filetype override, same format as 'commentstring'

if exists('g:loaded_commanter')
  finish
endif
g:loaded_commanter = 1

const DEFAULTS: dict<string> = {
  typst: '// %s',
  json: '// %s',
  conf: '# %s',
  dosbatch: 'REM %s',
  ps1: '# %s',
}

# Returns [left, right] marker parts for the current buffer.
def Parts(): list<string>
  var user: dict<any> = get(g:, 'commanter_markers', {})
  var fmt = ''
  if has_key(user, &filetype)
    fmt = user[&filetype]
  elseif &filetype == 'vim'
    var v9 = !empty(filter(getline(1, min([line('$'), 20])), (_, l) => l =~ '^\s*vim9script\>'))
    fmt = v9 ? '# %s' : '" %s'
  elseif has_key(DEFAULTS, &filetype)
    fmt = DEFAULTS[&filetype]
  else
    fmt = &commentstring
  endif
  var idx = stridx(fmt, '%s')
  if idx < 0
    return ['', '']
  endif
  return [trim(strpart(fmt, 0, idx)), trim(strpart(fmt, idx + 2))]
enddef

def Blank(line: string): bool
  return line =~ '^\s*$'
enddef

def Warn(): void
  echohl WarningMsg
  echo 'commanter: no comment marker for filetype "' .. &filetype .. '"'
  echohl None
enddef

def DoComment(l1: number, l2: number): void
  var [lft, rgt] = Parts()
  if empty(lft)
    Warn()
    return
  endif
  var indent = -1
  for n in range(l1, l2)
    var line = getline(n)
    if Blank(line)
      continue
    endif
    var w = strlen(matchstr(line, '^\s*'))
    if indent < 0 || w < indent
      indent = w
    endif
  endfor
  if indent < 0
    return
  endif
  for n in range(l1, l2)
    var line = getline(n)
    if Blank(line)
      continue
    endif
    var out = strpart(line, 0, indent) .. lft .. ' ' .. strpart(line, indent)
    if !empty(rgt)
      out ..= ' ' .. rgt
    endif
    setline(n, out)
  endfor
enddef

def DoUncomment(l1: number, l2: number): void
  var [lft, rgt] = Parts()
  if empty(lft)
    Warn()
    return
  endif
  var pat = '^\(\s*\)\V' .. escape(lft, '\') .. '\m \=\(.\{-}\)'
  if !empty(rgt)
    pat ..= '\m \=\V' .. escape(rgt, '\') .. '\m\s*'
  endif
  pat ..= '\m$'
  for n in range(l1, l2)
    var m = matchlist(getline(n), pat)
    if !empty(m)
      setline(n, m[1] .. m[2])
    endif
  endfor
enddef

def DoToggle(l1: number, l2: number): void
  var [lft, _] = Parts()
  if empty(lft)
    Warn()
    return
  endif
  var pat = '^\s*\V' .. escape(lft, '\')
  var all = true
  var any = false
  for n in range(l1, l2)
    var line = getline(n)
    if Blank(line)
      continue
    endif
    any = true
    if line !~ pat
      all = false
      break
    endif
  endfor
  if any && all
    DoUncomment(l1, l2)
  else
    DoComment(l1, l2)
  endif
enddef

command! -range Comment call DoComment(<line1>, <line2>)
command! -range Uncomment call DoUncomment(<line1>, <line2>)
command! -range CommentToggle call DoToggle(<line1>, <line2>)

def Map(lhs: string, cmd: string): void
  if empty(lhs)
    return
  endif
  execute 'nnoremap <silent> ' .. lhs .. ' <Cmd>execute ".,.+" .. (v:count1 - 1) .. "' .. cmd .. '"<CR>'
  execute 'xnoremap <silent> ' .. lhs .. ' :' .. cmd .. '<CR>'
enddef

Map(get(g:, 'commanter_map_comment', '<leader>c'), 'Comment')
Map(get(g:, 'commanter_map_uncomment', '<leader><space>'), 'Uncomment')
Map(get(g:, 'commanter_map_toggle', '<leader>,'), 'CommentToggle')
