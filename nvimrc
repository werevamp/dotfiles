set nocompatible

syntax enable
filetype plugin indent on

" Color
set background=dark
let base16colorspace=256  " Access colors present in 256 colorspace
let g:solarized_contrast="low"
let g:solarized_termcolors=256
let g:base16_shell_path="~/.config/base16-shell"
colorscheme base16-greenscreen
"hi NonText guifg=bg

"----------------------------
" Vim Defaults
"----------------------------

set hidden
set ruler
set number
set noswapfile
set linespace=0
set number
set title

" Set yanking to past to clipboard
set clipboard+=unnamedplus

" Scrolling
set scrolloff=8

" Indent
set autoindent
set noexpandtab
set shiftwidth=2
set tabstop=2

" Search
set hlsearch
set ignorecase
set smartcase
set incsearch

" Set file type
au BufRead,BufNewFile *.scss setfiletype scss
au BufRead,BufNewFile *.jade setfiletype jade
au BufRead,BufNewFile *.styl setfiletype=stylus
au BufRead,BufNewFile *.twig setfiletype=html
au! BufRead,BufNewFile *.json set filetype=json

" Set diff to be vertical windows
set diffopt+=vertical

"----------------------------
" My Keybindings
"----------------------------

" Reset Leaderkeys
let maplocalleader = "\\"
let mapleader = ","

" Reversed the back to line buttons
nnoremap ' `
nnoremap ` '

nnoremap H ^
nnoremap L g_
vnoremap H ^
vnoremap L g_

nnoremap <tab> %
vnoremap <tab> %

nnoremap ; :
nnoremap : ;

" Binding for command line mode
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-b> <Left>
cnoremap <c-f> <Right>
cnoremap <c-d> <Delete>
cnoremap <m-b> <S-Left>
cnoremap <m-f> <S-Right>
cnoremap <m-d> <S-right><Delete>
cnoremap <esc>b <S-Left>
cnoremap <esc>f <S-Right>
cnoremap <esc>d <S-right><Delete>
cnoremap <c-g>  <c-c>

" Remove Highlight
nnoremap <leader><space> :nohl<cr>

" Save and Quit
nnoremap <leader>qe :q!<CR>
nnoremap <leader>w :w!<CR>
"nnoremap <silent> <Leader>d :bd<CR>

" Switch Page
nnoremap <c-k> :bnext<CR>
nnoremap <c-j> :bprev<CR>

" Split a line in 2
nnoremap S i<cr><esc>

" Tabbing shortcut
nmap ) >>
nmap ( <<

" Fixed multiline tabbing
vnoremap > >gv
vnoremap < <gv

" Resize Screen
nnoremap <Right> :vertical resize +5<CR>
nnoremap <Left> :vertical resize -5<CR>
nnoremap <Down> :resize +5<CR>
nnoremap <Up> :resize -5<CR>

nnoremap <S-x> <C-a>

" Toggle colorcolumn 
set colorcolumn=81
let s:color_column_old = 0

function! s:ToggleColorColumn()
    if s:color_column_old == 0
        let s:color_column_old = &colorcolumn
        windo let &colorcolumn = 0
    else
        windo let &colorcolumn=s:color_column_old
        let s:color_column_old = 0
    endif
endfunction

nnoremap <silent> <F3> :call <SID>ToggleColorColumn()<cr>

" Folding
set foldlevelstart=0
nnoremap <Space> za
vnoremap <Space> zf

fun! FoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let folderlinecount = v:foldend - v:foldstart

    let onetab = strpart('    ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 - len(folderlinecount))
    let fillcharcount = windowwidth - len(line) - len(folderlinecount)
    return line . repeat(" ", fillcharcount) . '  ' . folderlinecount . '  ' 
endfun
set foldtext=FoldText()



 "Delete buffer while keeping window layout (don't close buffer's windows).  " Version 2008-11-18 from http://vim.wikia.com/wiki/VimTip165
if v:version < 700 || exists('loaded_bclose') || &cp
	finish
endif
let loaded_bclose = 1
if !exists('bclose_multiple')
	let bclose_multiple = 1
endif

" Display an error message.
function! s:Warn(msg)
	echohl ErrorMsg
	echomsg a:msg
	echohl NONE
endfunction

 "Command ':Bclose' executes ':bd' to delete buffer in current window.
 "The window will show the alternate buffer (Ctrl-^) if it exists,
 "or the previous buffer (:bp), or a blank buffer if no previous.
 "Command ':Bclose!' is the same, but executes ':bd!' (discard changes).
 "An optional argument can specify which buffer to close (name or number).
function! s:Bclose(bang, buffer)
	if empty(a:buffer)
		let btarget = bufnr('%')
	elseif a:buffer =~ '^\d\+$'
		let btarget = bufnr(str2nr(a:buffer))
	else
		let btarget = bufnr(a:buffer)
	endif
	if btarget < 0
		call s:Warn('No matching buffer for '.a:buffer)
		return
	endif
	if empty(a:bang) && getbufvar(btarget, '&modified')
		call s:Warn('No write since last change for buffer '.btarget.' (use :Bclose!)')
		return
	endif
	" Numbers of windows that view target buffer which we will delete.
	let wnums = filter(range(1, winnr('$')), 'winbufnr(v:val) == btarget')
	if !g:bclose_multiple && len(wnums) > 1
		call s:Warn('Buffer is in multiple windows (use ":let bclose_multiple=1")')
		return
	endif
	let wcurrent = winnr()
	for w in wnums
		execute w.'wincmd w'
		let prevbuf = bufnr('#')
		if prevbuf > 0 && buflisted(prevbuf) && prevbuf != w
			buffer #
		else
			bprevious
		endif
		if btarget == bufnr('%')
			" Numbers of listed buffers which are not the target to be deleted.
			let blisted = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != btarget')
			" Listed, not target, and not displayed.
			let bhidden = filter(copy(blisted), 'bufwinnr(v:val) < 0')
			" Take the first buffer, if any (could be more intelligent).
			let bjump = (bhidden + blisted + [-1])[0]
			if bjump > 0
				execute 'buffer '.bjump
			else
				execute 'enew'.a:bang
			endif
		endif
	endfor
	execute 'bdelete'.a:bang.' '.btarget
	execute wcurrent.'wincmd w'
endfunction
command! -bang -complete=buffer -nargs=? Bclose call s:Bclose('<bang>', '<args>')
nnoremap <silent> <Leader>d :Bclose<CR>

"----------------------------
" Plugin Settings
"----------------------------

" Airline
let g:airline#extensions#tabline#enabled = 1
set laststatus=2

let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" Indent Guide
let g:indent_guides_color_change_percent = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_exclude_filetypes = ['nerdtree']

autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#222222 ctermbg=237
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#111111 ctermbg=235

" NERDTree
nnoremap <F2> :NERDTreeToggle<cr>

" Emmet
let g:user_emmet_mode='i'
let g:user_emmet_expandabbr_key = '<C-D>'
let g:user_emmet_next_key = '<C-K>'
let g:user_emmet_prev_key = '<C-J>'

" You Complete Me
autocmd FileType c nnoremap <buffer> <silent> <C-]> :YcmCompleter GoTo<cr>

" Better CSS Syntax for Vim
setlocal iskeyword+=-
augroup VimCSS3Syntax
	autocmd!

	autocmd FileType css setlocal iskeyword+=-
augroup END

" GitGutter
let g:gitgutter_enabled = 1

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_php_checkers = ["php", "phpcs", "phpmd"]

" Tmuxline
let g:tmuxline_theme = 'airline_insert'
let g:airline#extensions#tmuxline#enabled = 0
let g:tmuxline_preset = {
      \'a'    : '#S',
      \'win'  : ['#I', '#W'],
      \'cwin' : ['#I', '#W'],
      \'y'    : ['%a', '%l:%M %p', '%x'],
      \'z'    : '#h'}

" You Complete Me
let g:ycm_always_populate_location_list = 1

"----------------------------
" VimPlug Package Manager
"----------------------------

call plug#begin('~/.nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tomasr/molokai'
Plug 'vyshane/vydark-vim-color'
Plug 'bling/vim-airline'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'altercation/solarized'
Plug 'Lokaltog/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'hail2u/vim-css3-syntax'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'mattn/emmet-vim'
Plug 'ervandew/supertab'
Plug 'airblade/vim-gitgutter'
Plug 'pangloss/vim-javascript'
Plug 'cohama/agit.vim'
Plug 'othree/html5.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'chriskempson/base16-vim'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/syntastic'
Plug 'Valloric/YouCompleteMe'
Plug 'kien/ctrlp.vim'

call plug#end()

