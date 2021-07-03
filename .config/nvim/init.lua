local datapath = vim.fn.stdpath('data')

if vim.env.TERM ~= 'linux' then
	vim.opt.termguicolors = true
end

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 6
vim.opt.lazyredraw = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.list = true
vim.opt.listchars = { tab = '  ', extends = '>', precedes = '<', nbsp = '~' }
vim.opt.background = 'dark'
vim.opt.laststatus = 1
vim.opt.helpheight = 0
vim.opt.title = true
vim.opt.titlestring = 'nvim %f %m'
vim.opt.mouse = 'nv'
vim.opt.undofile = true
vim.opt.formatoptions = 'croq1jp'
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect' }
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0
vim.opt.smartindent = true
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = 'syntax'
vim.opt.diffopt = { 'filler', 'iwhite', 'closeoff', 'internal', 'indent-heuristic' }
vim.opt.wildmode = { 'longest:full', 'full' }
vim.opt.virtualedit = 'block'
vim.opt.inccommand = 'nosplit'
vim.opt.clipboard = 'unnamed'

vim.cmd[==[
au FileType tex setlocal spell
au FileType markdown setlocal spell tw=80
au FileType markdown compiler markdown
"au FileType python setlocal foldmethod=indent
au FileType cs compiler dotnet
au BufWritePre /tmp/* setlocal noundofile
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') && &ft !~# 'commit' | exe 'normal! g`"' | endif

com! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
com! -bang W lua SudoWrite('<bang>' == '!')

hi Error        guibg=DarkRed
hi ErrorMsg     guibg=DarkRed
hi Folded       guibg=NONE guifg=Cyan
hi Pmenu        guibg=#222222
hi PmenuSel     guibg=#444444 guifg=White
hi NormalFloat  guibg=#222222 guifg=White
hi SpellBad     NONE guifg=Red
hi SpellCap     NONE guifg=Orange
hi SpellRare    NONE guifg=Yellow
hi Visual       guibg=#403d3d
hi debugPC      guibg=DarkBlue
hi NonText      guifg=DarkCyan
hi manUnderline guifg=Green
hi manBold      gui=bold
]==]

vim.g.netrw_banner = 0
vim.g.python_recommended_style = 0
vim.g.tex_comment_nospell = 1
vim.g.tex_fold_enabled = 1
vim.g.man_hardwrap = 0

vim.api.nvim_set_keymap('n', '<Leader>/', '<Cmd>noh<CR>', {})
vim.api.nvim_set_keymap('n', 'Y', 'y$', {})
vim.api.nvim_set_keymap('n', 'gb', '<Cmd>lua GitBlame()<CR>', {})
vim.api.nvim_set_keymap('v', '<Leader>w', '<Cmd>lua VisualWc()<CR>', {})
vim.api.nvim_set_keymap('v', '<LeftRelease>', 'y', {})
vim.api.nvim_set_keymap('i', '<C-H>', '<C-W>', {})

function SudoWrite(sure)
	if not sure then
		print 'Add ! to use sudo.'
	else
		vim.cmd([[
			w! /tmp/sudonvim
			bel 2new
			startinsert
			te </tmp/sudonvim sudo tee >/dev/null ]]..vim.fn.shellescape(vim.fn.expand('%'))
		)
	end
end

function GitBlame()
	if vim.w.gitblame_open then
		vim.cmd('close '..vim.w.gitblame_open)
		vim.w.gitblame_open = nil
	else
		local winnr = vim.fn.winnr()
		local width = vim.fn.winwidth(winnr)
		vim.cmd 'vnew'
		vim.w.gitblame_open = winnr
		vim.opt_local.buftype = 'nofile'
		vim.cmd('r!git blame '..vim.fn.shellescape(vim.fn.expand('#'))..[[|sed 's/(//;s/\s\+[0-9]\+)\s.*$//']])
		vim.cmd '0d_'
		vim.opt_local.filetype = 'gitblame'
		vim.opt_local.wrap = false
		vim.cmd('vert res '..math.min(vim.fn.col('$') - 1, width / 3))
		vim.opt_local.scrollbind = true
		vim.cmd 'winc p'
		vim.opt_local.scrollbind = true
		vim.cmd 'sync'
		vim.w.gitblame_open = winnr
	end
end

function VisualWc()
	local wc = vim.fn.wordcount()
	local lines = 1-vim.fn.line("'<")+vim.fn.line("'>")
	print(lines, wc.visual_words, wc.visual_chars, '\n')
end


if vim.fn.exists('g:vscode') == 1 then return end


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
local Plug = vim.fn['plug#']

Plug 'junegunn/vim-easy-align'
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

Plug 'bogado/file-line'

-- Plug 'sakhnik/nvim-gdb'

-- vim.lsp.set_log_level('trace');

Plug 'neovim/nvim-lspconfig'
table.insert(after, function()
	local lspconfig = require 'lspconfig'
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	local on_attach = function(client, bufnr)
		local function buf_set_keymap(mode, lhs, rhs)
			vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { noremap = true, silent = true })
		end
		local function buf_set_option(...)
			vim.api.nvim_buf_set_option(bufnr, ...)
		end

		buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

		-- Mappings.
		buf_set_keymap('n', 'gD',    '<Cmd>lua vim.lsp.buf.declaration()<CR>')
		buf_set_keymap('n', 'gd',    '<Cmd>lua vim.lsp.buf.definition()<CR>')
		buf_set_keymap('n', 'K',     '<Cmd>lua vim.lsp.buf.hover()<CR>')
		buf_set_keymap('n', 'gi',    '<Cmd>lua vim.lsp.buf.implementation()<CR>')
		buf_set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', '<silent>')
		buf_set_keymap('n', ' wa',   '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
		buf_set_keymap('n', ' wr',   '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
		buf_set_keymap('n', ' wl',   '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
		buf_set_keymap('n', ' D',    '<Cmd>lua vim.lsp.buf.type_definition()<CR>')
		buf_set_keymap('n', ' r',    '<Cmd>lua vim.lsp.buf.rename()<CR>')
		buf_set_keymap('n', 'gr',    '<Cmd>lua vim.lsp.buf.references()<CR>')
		buf_set_keymap('n', ' e',    '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
		buf_set_keymap('n', '[d',    '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
		buf_set_keymap('n', ']d',    '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
		buf_set_keymap('n', ' q',    '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>')
		buf_set_keymap('n', ' a',    '<Cmd>lua vim.lsp.buf.code_action()<CR>')

		-- Set some keybinds conditional on server capabilities
		if client.resolved_capabilities.document_formatting then
			buf_set_keymap('n', ' f', ':lua vim.lsp.buf.formatting()<CR>')
		end
		if client.resolved_capabilities.document_range_formatting then
			buf_set_keymap('v', ' f', ':lua vim.lsp.buf.range_formatting()<CR>')
		end
	end

	lspconfig.clangd.setup{
		capabilities = capabilities, on_attach = on_attach,
		cmd = { 'clangd', '--background-index', '--clang-tidy', '--completion-style=detailed', '--header-insertion=iwyu' },
	}
	lspconfig.html.setup{
		capabilities = capabilities, on_attach = on_attach,
		cmd = { 'vscode-html-languageserver', '--stdio' },
	}
	lspconfig.cssls.setup{
		capabilities = capabilities, on_attach = on_attach,
		cmd = { 'vscode-css-languageserver', '--stdio' },
	}
	lspconfig.jsonls.setup{
		capabilities = capabilities, on_attach = on_attach,
		cmd = { 'vscode-json-languageserver', '--stdio' },
	}
	lspconfig.tsserver.setup{
		capabilities = capabilities, on_attach = on_attach,
	}
	lspconfig.pyright.setup{
		capabilities = capabilities, on_attach = on_attach,
	}
	lspconfig.texlab.setup{
		capabilities = capabilities, on_attach = on_attach,
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
			},
		},
	}
	lspconfig.omnisharp.setup{
		capabilities = capabilities, on_attach = on_attach,
		cmd = { 'omnisharp', '-lsp', '-hpid', tostring(vim.fn.getpid()) },
	}
end)

Plug 'nvim-lua/completion-nvim'
vim.g.completion_sorting = 'none'
vim.g.completion_enable_snippet = 'vim-vsnip'
vim.g.completion_matching_smart_case = 1
vim.cmd[[autocmd BufEnter * lua require'completion'.on_attach()]]

--Plug 'norcalli/snippets.nvim'
--table.insert(after, function()
--	local snippets = require 'snippets'
--	snippets.use_suggested_mappings()
--	-- snippets.set_ux(require'snippets.inserters.floaty')
--	snippets.snippets = {
--	}
--end)

Plug 'hrsh7th/vim-vsnip'
vim.g.vsnip_snippet_dir = vim.fn.stdpath('config')..'/vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
vim.cmd[[
imap <expr> <C-j>   vsnip#available(1)  ? '<Plug>(vsnip-expand)'         : '<C-j>'
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
imap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
]]

Plug 'qpkorr/vim-renamer'
vim.g.RenamerSupportColonWToRename = 1

Plug 'peterhoeg/vim-qml'

vim.call('plug#end')

for k,v in pairs(vim.g.plugs) do
	if vim.fn.isdirectory(v.dir) == 0 then
		vim.cmd[[PlugInstall --sync]]
		break
	end
end


for k,v in ipairs(after) do
	v()
end
