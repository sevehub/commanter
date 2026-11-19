# commanter

Comment, uncomment or toggle lines and ranges in Vim. Pure vim9script, single file, no dependencies.

Requires Vim 9.0+.

## Install

Copy the folders into your runtime path:

- Windows: `%USERPROFILE%\vimfiles\`
- Linux/macOS: `~/.vim/`

Or clone into a package directory, for example `~/.vim/pack/plugins/start/commanter`.
Then run `:helptags ALL` (or `:helptags ~/.vim/doc`) to enable `:help commanter`.

## Default keys

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>c` | normal | comment current line (accepts a count, `3<leader>c`) |
| `<leader>c` | visual | comment selection |
| `<leader><space>` | normal | uncomment current line (accepts a count) |
| `<leader><space>` | visual | uncomment selection |
| `<leader>,` | normal | toggle current line (accepts a count) |
| `<leader>,` | visual | toggle selection |

## Commands

| Command | Action |
| --- | --- |
| `:[range]Comment` | comment lines |
| `:[range]Uncomment` | uncomment lines |
| `:[range]CommentToggle` | uncomment if every non-blank line is commented, otherwise comment |

## Settings

Set before the plugin loads (in `vimrc`).

```vim
g:commanter_map_comment   = '<leader>c'        " '' disables
g:commanter_map_uncomment = '<leader><space>'  " '' disables
g:commanter_map_toggle    = '<leader>,'        " '' disables
g:commanter_markers       = {python: '# %s', html: '<!-- %s -->'}
```

In legacy vimscript use `let g:...` instead.

`g:commanter_markers` maps a filetype to a string in the same format as `'commentstring'`, with `%s` marking where the text goes.

## Ctrl-, (optional)

`Ctrl-,` works in gVim and in terminals that support modifyOtherKeys or the kitty keyboard protocol. Most plain terminals send a bare `,` for it, so the mapping never fires there.

```vim
g:commanter_map_toggle = '<C-,>'
```

If `mapleader` is `,`, the default toggle becomes `,,` and plain `,` waits for `timeoutlen` before repeating an `f`/`t` search. Pick another toggle key in that case.

## Behavior

- Markers come from `g:commanter_markers`, then built-in defaults (typst, json, conf, dosbatch, ps1), then `'commentstring'`.
- `.vim` files use `#` when `vim9script` appears in the first 20 lines, otherwise `"`.
- Comments align at the lowest indent in the range; blank lines are skipped.
- Block markers such as `<!-- %s -->` are supported.
- Uncomment removes the marker plus one following space, and the closing marker if present. Lines without the marker are left alone.
- Filetypes without a usable marker produce a warning and no change.

## Known limits

- Indent alignment is byte-based; ranges that mix tabs and spaces in a single indent can misalign.
- Nested comments are not tracked: commenting an already commented line adds a second marker, and uncomment removes one level.
- Not covered by automated tests.

## License

MIT
