local datapath = vim.fn.stdpath('data')

if vim.env.TERM ~= 'linux' then
	vim.o.termguicolors = true
end

vim.cmd[[
set smartcase
set scrolloff=3 sidescrolloff=6 lazyredraw
set linebreak breakindent breakindentopt=shift:2,sbr showbreak=↳
set list listchars=tab:\ \ ,extends:>,precedes:<,nbsp:~
set background=dark
set laststatus=1 helpheight=0
set title
set mouse=nv
set undofile formatoptions=croq1jp completeopt=menuone,noinsert,noselect,preview
set tabstop=2 shiftwidth=0 smartindent
set foldlevelstart=99 foldmethod=syntax
set diffopt=filler,iwhite,closeoff,internal,indent-heuristic
set wildmode=longest:full,full
set virtualedit=block
set inccommand=nosplit
set clipboard=unnamed
]]

vim.cmd[[au FileType tex setlocal spell]]
vim.cmd[[au FileType markdown setlocal spell ts=8 sw=3 et]]
vim.cmd[[au FileType markdown compiler markdown]]
vim.cmd[[au FileType python setlocal foldmethod=indent]]
vim.cmd[[au FileType cs compiler dotnet]]
vim.cmd[[au BufWritePre /tmp/* setlocal noundofile]]
vim.cmd[[au BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') && &ft !~# 'commit'
	exe 'normal! g`"'
endif
]]

vim.g.netrw_banner = 0
vim.g.python_recommended_style = 0
vim.g.tex_comment_nospell = 1
vim.g.tex_fold_enabled = 1
vim.g.man_hardwrap = 0

vim.cmd[[
hi Error        guibg=DarkRed
hi ErrorMsg     guibg=DarkRed
hi Folded       guibg=NONE guifg=Cyan
hi Pmenu        guibg=DarkMagenta
hi PmenuSel     guibg=Magenta guifg=Blue 
hi SpellBad     NONE guifg=Red
hi SpellCap     NONE guifg=Orange
hi SpellRare    NONE guifg=Yellow
hi Visual       guibg=#403d3d
hi debugPC      guibg=DarkBlue
hi NonText      guifg=DarkCyan
hi manUnderline guifg=Green
hi manBold      gui=bold
]]

vim.cmd(
	'command! DiffOrig vert new | set bt=nofile | r ++edit #'
	..' | 0d_ | diffthis | wincmd p | diffthis')

vim.api.nvim_set_keymap('n', '<Leader>/', '<Cmd>noh<CR>', {})
vim.api.nvim_set_keymap('n', 'Y', 'y$', {})
vim.api.nvim_set_keymap('v', '<Leader>w', '<Cmd>lua VisualWc()<CR>', {})

function VisualWc()
	local wc = vim.fn.wordcount()
	local lines = 1-vim.fn.line("'<")+vim.fn.line("'>")
	print(lines, wc.visual_words, wc.visual_chars)
end

local function executable(cmd)
	return vim.fn.executable(cmd) == 1
end

if executable('curl') and vim.fn.filereadable(datapath..'/site/autoload/plug.vim') == 0 then
	print 'Downloading vim-plug...'
	vim.fn.jobstart({ 'curl', '--create-dirs', '-fLo', datapath..'/site/autoload/plug.vim',
		'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' },
		{ on_exit = function (id, code, t)
			if code == 0 then
				print 'Downloading vim-plug succeeded, reloading config...'
				vim.cmd[[luafile $MYVIMRC]]
			else
				print 'Downloading vim-plug failed, will try again next time.'
			end
		end
	})
	return
end

local after = {}

vim.call('plug#begin', datapath..'/plugged')

vim.fn['plug#'] 'junegunn/vim-easy-align'
vim.cmd[[xmap ga <Plug>(EasyAlign)]]
vim.cmd[[nmap ga <Plug>(EasyAlign)]]
vim.g.easy_align_delimiters = {
	['/'] = {
		pattern         = [[//\+\|/\*\|\ \*]],
		delimiter_align = 'l',
		ignore_groups   = {},
	},
	['\\'] = {
		pattern         = [[\\]],
		indentation     = 'keep',
		left_margin     = 1,
		delimiter_align = 'center',
		ignore_groups   = {'String', 'Comment'},
	},
}
vim.cmd[[autocmd FileType markdown imap <buffer> <Bar> <Bar><Esc>m`gaip*<Bar>``A]]

vim.fn['plug#'] 'bogado/file-line'

-- vim.fn['plug#'] 'sakhnik/nvim-gdb'

vim.fn['plug#'] 'neovim/nvim-lspconfig'
vim.cmd[[
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
]]
table.insert(after, function()
	local lspconfig = require 'lspconfig'
	if false and executable('ccls') then
		lspconfig.ccls.setup{}
	elseif executable('clangd') then
		lspconfig.clangd.setup{}
	end
	if executable('npm') then
		lspconfig.html.setup{}
		if executable('tsserver') then
			lspconfig.tsserver.setup{}
		end
	end
	if executable('pyls') then
		lspconfig.pyls.setup{}
	end
	if executable('texlab') then
		lspconfig.texlab.setup{
			commands = {
				TexlabForwardSearch = {
					function()
						local pos = vim.api.nvim_win_get_cursor(0)
						local params = {
							textDocument = { uri = vim.uri_from_bufnr(0) },
							position = { line = pos[1] - 1, character = pos[2] },
						}
						vim.lsp.buf_request(0, 'textDocument/forwardSearch', params, function(err, _, result, _)
							if err then error(tostring(err)) end
							print('Forward search ' .. vim.inspect(pos) .. ' ' .. texlab_search_status[result])
						end)
					end;
					description = 'Run synctex forward search'
				},
			},
			settings = {
				latex = {
					build = {
						executable = 'latexmk',
						args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '-lualatex', '-outdir=build', '%f' },
						outputDirectory = 'build',
						onSave = true,
					},
					forwardSearch = {
						executable = 'llpp.inotify',
						args = { '%p' },
					},
					lint = {
						onChange = false,
					},
				},
			},
		}
	end
	if executable('dotnet') then
		lspconfig.omnisharp.setup{}
	end
end)

vim.fn['plug#'] 'nvim-lua/completion-nvim'
table.insert(after, function()
	vim.g.completion_sorting = 'none'
	vim.cmd[[autocmd BufEnter * lua require'completion'.on_attach()]]
	vim.cmd[[autocmd CompleteDone * pclose]]
end)

vim.fn['plug#'] 'hrsh7th/vim-vsnip'
vim.fn['plug#'] 'hrsh7th/vim-vsnip-integ'
vim.cmd[[
imap <expr> <C-j>   vsnip#available(1)  ? '<Plug>(vsnip-expand)'         : '<C-j>'
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
imap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
]]

vim.fn['plug#'] 'qpkorr/vim-renamer'
vim.g.RenamerSupportColonWToRename = 1

vim.call('plug#end')

for k,v in pairs(vim.g.plugs) do
	if vim.fn.isdirectory(v.dir) == 0 then
		vim.cmd[[PlugInstall --sync]]
		break
	end
end


for k,v in ipairs(after) do
	v();
end
