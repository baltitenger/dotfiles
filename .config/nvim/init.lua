local datapath = vim.fn.stdpath('data')
local autocmd = vim.api.nvim_create_autocmd

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
vim.opt.mouse = 'v'
vim.opt.undofile = true
vim.opt.formatoptions = 'croq1j'
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect' }
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0
vim.opt.smartindent = true
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = 'marker'
vim.opt.diffopt = { 'filler', 'iwhite', 'closeoff', 'internal', 'indent-heuristic' }
vim.opt.wildmode = { 'longest:full', 'full' }
vim.opt.inccommand = 'nosplit'
vim.opt.clipboard = 'unnamed'

autocmd('FileType', { pattern = 'tex', callback = function()
	vim.opt_local.spell = true
	local tmp = vim.g.easy_align_delimiters
	tmp['\\'] = {
		pattern         = [[\\\\]],
		delimiter_align = 'center',
	}
	vim.g.easy_align_delimiters = tmp
end})
autocmd('FileType', { pattern = 'markdown', command = [[
	setlocal spell tw=80
	compiler markdown
]]})
autocmd('FileType', { pattern = 'cs', command = [[compiler dotnet]]})
autocmd('FileType', { pattern = 'haskell', command = [[set ts=8 sw=2 et]]})

autocmd('BufNewFile', { nested = true, callback = function(info)
	local match = vim.fn.matchlist(info.file, [[^\(.\{-1,}\)[(:]\(\d\+\)\%(:\(\d\+\):\?\)\?$]])
	if #match == 0 then return end
	local file, row, col = match[2], tonumber(match[3]), tonumber('0'..match[4])
	if vim.fn.filereadable(file) == 0 then return end
	vim.cmd('keepalt edit +'..row..' '..vim.fn.fnameescape(file))
	if col > 1 then
		vim.cmd('normal! 0'..(col-1)..'l')
	else
		vim.cmd('normal! 0')
	end
end})

vim.cmd[==[
au BufWritePre /tmp/* setlocal noundofile
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') && &ft !~# 'commit' | exe 'normal! g`"' | endif
au BufNewFile,BufRead *.zig setf zig

com! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
com! -bang W lua SudoWrite('<bang>' == '!')

hi Error        guibg=DarkRed
hi ErrorMsg     guibg=DarkRed
hi Folded       guibg=NONE guifg=Cyan
hi Pmenu        guibg=#222222
hi PmenuSel     guibg=#444444 guifg=White
hi NormalFloat  guibg=#222222 guifg=White
hi FloatBorderT guifg=#222222
hi SpellBad     NONE guifg=Red
hi SpellCap     NONE guifg=Orange
hi SpellRare    NONE guifg=Yellow
hi Visual       guibg=#403d3d
hi debugPC      guibg=DarkBlue
hi NonText      guifg=DarkCyan
hi manUnderline guifg=Green
hi manBold      gui=bold
hi link texOnlyMath NONE
hi LspSignatureActiveParameter guibg=DarkRed
hi def Dim guifg=grey
]==]

local floatBorder = {
	{ '▗', 'FloatBorderT' },
	{ '▄', 'FloatBorderT' },
	{ '▖', 'FloatBorderT' },
	{ '▌', 'FloatBorderT' },
	{ '▘', 'FloatBorderT' },
	{ '▀', 'FloatBorderT' },
	{ '▝', 'FloatBorderT' },
	{ '▐', 'FloatBorderT' },
}

vim.g.netrw_banner = 0
vim.g.python_recommended_style = 0
vim.g.tex_comment_nospell = 1
vim.g.tex_fold_enabled = 1
vim.g.tex_flavor = 'latex'
vim.g.html_indent_script1 = 'inc'
vim.g.html_indent_style1 = 'inc'

local function executable(cmd)
	return vim.fn.executable(cmd) == 1
end

function SudoWrite(sure)
	if not sure then
		print 'Add ! to use sudo.'
	else
		vim.cmd[[
			w! /tmp/sudonvim
			bel 2new
			startinsert
			te sudo tee #:S </tmp/sudonvim >/dev/null; rm /tmp/sudonvim
		]]
	end
end

function GitBlame()
	if vim.w.gitblame_open then
		vim.cmd('close '..vim.w.gitblame_open)
		vim.w.gitblame_open = nil
	else
		local winnr = vim.fn.winnr()
		local width = vim.fn.winwidth(winnr)
		vim.cmd[[
			vnew
			r !git blame #:S | sed 's/(//;s/\s\+[0-9]\+)\s.*$//'
			0d_
		]]
		vim.w.gitblame_open = winnr
		vim.opt_local.buftype = 'nofile'
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

comment_map = {
	c          = '//',
	cpp        = '//',
	cs         = '//',
	go         = '//',
	java       = '//',
	jsonc      = '//',
	javascript = '//',
	javascriptreact = '//',
	typescript = '//',
	typescriptreact = '//',
	php        = '//',
	rust       = '//',
	scala      = '//',
	conf       = '#',
	cmake      = '#',
	desktop    = '#',
	fstab      = '#',
	make       = '#',
	python     = '#',
	ruby       = '#',
	sh         = '#',
	i3config   = '#',
	perl       = '#',
	yaml       = '#',
	bat        = 'REM',
	lua        = '--',
	haskell    = '--',
	mail       = '>',
	tex        = '%',
	vim        = '"',
}

function ToggleComment(type)
	local prefix = comment_map[vim.o.filetype]
	if not prefix then
		return vim.api.nvim_err_writeln 'No comment prefix defined for this filetype!'
	end
	local first = vim.fn.line "'[" - 1
	local last  = vim.fn.line "']"
	local lines = vim.api.nvim_buf_get_lines(0, first, last, true)
	local all_comment = true
	local uncommented = {}
	local shallowest = 1e99
	for i,line in ipairs(lines) do
		local depth = line:find('[^%s]')
		if depth then
			shallowest = math.min(shallowest, depth)
			local res, success = line:gsub('^(%s*)' .. vim.pesc(prefix) .. ' ?', '%1', 1)
			if success == 0 then
				all_comment = false
			end
			table.insert(uncommented, res)
		else
			table.insert(uncommented, line)
		end
	end
	if all_comment then
		return vim.api.nvim_buf_set_lines(0, first, last, true, uncommented);
	end
	for i,line in ipairs(lines) do
		if line:len() >= shallowest - 1 then
			lines[i] = line:sub(0, shallowest - 1) .. prefix .. ' ' .. line:sub(shallowest)
		end
	end
	vim.api.nvim_buf_set_lines(0, first, last, true, lines);
end

function ToggleBraces()
	local l = vim.api.nvim_win_get_cursor(0)[1] - 2
	local lines = vim.api.nvim_buf_get_lines(0, l, l+3, true)
	print(vim.inspect(lines))
	local prev, succ1 = string.gsub(lines[1], '%s*{$', '')
	local succ2 = string.match(lines[3], '^%s*}$')
	if succ1 == 1 and succ2 then
		lines[1] = prev
		table.remove(lines)
	else
		lines[1] = lines[1] .. ' {'
		table.insert(lines, #lines, string.match(lines[1], '^%s*') .. '}')
	end
	vim.api.nvim_buf_set_lines(0, l, l+3, true, lines)
end

-- function osccopy(sel)
-- 	return function(lines, _)
-- 		local job = vim.fn.jobstart({'base64', '-w0'}, {
-- 			stdout_buffered = true,
-- 			on_stdout = function(_, data, _)
-- 				io.stdout:write('\027]52;'..sel..';'..data[1]..'\027\\')
-- 			end,
-- 		})
-- 		vim.fn.chansend(job, lines)
-- 		vim.fn.chanclose(job, 'stdin')
-- 	end
-- end

-- function oscpaste(sel)
-- 	return function()
-- 		io.stdout:write('\027]52;'..sel..';?\027\\')
-- 		return { { '' }, 'c' }
-- 	end
-- end

-- vim.cmd 'runtime autoload/provider/clipboard.vim'
-- if executable('base64') and vim.g.loaded_clipboard_provider ~= 2 then
-- 	vim.g.clipboard = {
-- 		name = 'OSC-52',
-- 		copy  = { ['*'] = osccopy  's', ['+'] = osccopy  'c' },
-- 		paste = { ['*'] = oscpaste 's', ['+'] = oscpaste 'c' },
-- 	}
-- 	vim.g.loaded_clipboard_provider = nil
-- 	vim.cmd 'runtime autoload/provider/clipboard.vim'
-- end

vim.keymap.set('n', '<Leader>/', '<Cmd>noh<CR>')
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set('n', 'gb', GitBlame)
-- vim.keymap.set('v', '<Leader>w', VisualWc)
vim.keymap.set('v', '<Leader>w', '<Cmd>lua VisualWc()<CR>') -- should convert to an operator probably
vim.keymap.set('i', '<C-BS>', '<C-W>')
vim.keymap.set('n', 'gcc', '<Cmd>set opfunc=v:lua.ToggleComment<CR>g@l')
vim.keymap.set('n', 'gc',  '<Cmd>set opfunc=v:lua.ToggleComment<CR>g@')
vim.keymap.set('v', 'gc',  '<Cmd>set opfunc=v:lua.ToggleComment<CR>g@')
vim.keymap.set('n', '<C-/>', 'gcc', { remap = true})
vim.keymap.set('v', '<C-/>', 'gc', { remap = true})
vim.keymap.set('n', '<M-h>', '<C-W>h')
vim.keymap.set('n', '<M-j>', '<C-W>j')
vim.keymap.set('n', '<M-k>', '<C-W>k')
vim.keymap.set('n', '<M-l>', '<C-W>l')
vim.keymap.set('n', 'É', ':')
vim.keymap.set('n', 'gs', ToggleBraces)


if vim.fn.exists('g:vscode') == 1 then return end


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

-- Plug 'bogado/file-line'

-- Plug 'sakhnik/nvim-gdb'

-- vim.lsp.set_log_level('trace');

Plug 'neovim/nvim-lspconfig'
table.insert(after, function()
	local lspconfig = require 'lspconfig'
	local test_ns = vim.api.nvim_create_namespace('test')
	vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = floatBorder,
	})
	vim.lsp.handlers['textDocument/publishDiagnostics'] = function(_, result, ctx, config)
		local bufnr = vim.uri_to_bufnr(result.uri)
		if not bufnr then
			return
		end
		vim.api.nvim_buf_clear_namespace(bufnr, test_ns, 0, -1)
		local real_diags = {}
		for _, diag in pairs(result.diagnostics) do
			if diag.tags and vim.tbl_contains(diag.tags, vim.lsp.protocol.DiagnosticTag.Unnecessary) then
				pcall(vim.api.nvim_buf_set_extmark, bufnr, test_ns,
						diag.range.start.line, diag.range.start.character, {
					end_row = diag.range['end'].line,
					end_col = diag.range['end'].character,
					hl_group = 'Dim',
				})
			else
				table.insert(real_diags, diag)
			end
		end
		result.diagnostics = real_diags
		vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
	end
	caps = require('cmp_nvim_lsp').default_capabilities()
	caps.textDocument.completion.completionItem.snippetSupport = true
	caps.textDocument.publishDiagnostics = {
		tagSupport = {
			valueSet = { 1 } 
		}
	}
	lspconfig.util.default_config.capabilities = caps
	lspconfig.util.default_config.on_attach = function(client, bufnr)
		-- Mappings.
		vim.keymap.set('n', 'gD',    vim.lsp.buf.declaration, {buffer=bufnr})
		vim.keymap.set('n', 'gd',    vim.lsp.buf.definition, {buffer=bufnr})
		vim.keymap.set('n', 'K',     vim.lsp.buf.hover, {buffer=bufnr})
		vim.keymap.set('n', 'gi',    vim.lsp.buf.implementation, {buffer=bufnr})
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, {buffer=bufnr})
		vim.keymap.set('n', ' wa',   vim.lsp.buf.add_workspace_folder, {buffer=bufnr})
		vim.keymap.set('n', ' wr',   vim.lsp.buf.remove_workspace_folder, {buffer=bufnr})
		vim.keymap.set('n', ' wl',   function() vim.pretty_print(vim.lsp.buf.list_workspace_folders()) end, {buffer=bufnr})
		vim.keymap.set('n', ' D',    vim.lsp.buf.type_definition, {buffer=bufnr})
		vim.keymap.set('n', ' r',    vim.lsp.buf.rename, {buffer=bufnr})
		vim.keymap.set('n', 'gr',    vim.lsp.buf.references, {buffer=bufnr})
		vim.keymap.set('n', ' e',    vim.diagnostic.open_float, {buffer=bufnr})
		vim.keymap.set('n', '[d',    vim.diagnostic.goto_prev, {buffer=bufnr})
		vim.keymap.set('n', ']d',    vim.diagnostic.goto_next, {buffer=bufnr})
		vim.keymap.set('n', ' q',    vim.diagnostic.setloclist, {buffer=bufnr})
		vim.keymap.set('n', ' a',    vim.lsp.buf.code_action, {buffer=bufnr})

		-- Set some keybinds conditional on server capabilities
		vim.opt_local.formatexpr = vim.go.formatexpr
		if client.server_capabilities.documentFormattingProvider then
			vim.keymap.set('n', ' f', function() vim.lsp.buf.format{} end, {buffer=bufnr})
		end
		if client.server_capabilities.documentRangeFormattingProvider then
			vim.keymap.set('v', ' f', function() vim.lsp.buf.format{}; vim.api.nvim_input('<Esc>') end, {buffer=bufnr})
		end

		-- workaround for omnisharp's messed up semantic tokens
		if client.name == 'omnisharp' then
			client.server_capabilities.semanticTokensProvider = nil
		end
	end

	local oldnotify = vim.notify
	vim.notify = function(msg, level, opts)
		if vim.startswith(msg, 'Spawning language server with cmd: ') then return end
		oldnotify(msg, level, opts)
	end

	lspconfig.clangd.setup{
		cmd = { 'clangd', '--background-index', '--clang-tidy', '--completion-style=detailed', '--header-insertion=iwyu', '--query-driver=/usr/bin/*,/home/baltazar/.espressif/tools/**/bin/*' },
	}
	lspconfig.html.setup{
		cmd = { 'vscode-html-languageserver', '--stdio' },
	}
	lspconfig.cssls.setup{
		cmd = { 'vscode-css-languageserver', '--stdio' },
	}
	-- lspconfig.jsonls.setup{
	-- 	cmd = { 'vscode-json-languageserver', '--stdio' },
	-- }
	lspconfig.tsserver.setup{}
	lspconfig.pyright.setup{}
	--lspconfig.jedi_language_server.setup{}
	lspconfig.texlab.setup{
		settings = {
			texlab = {
				build = {
					executable = 'latexmk',
					args = {
						'-pdf',
						'-interaction=nonstopmode',
						'-synctex=1',
						'-lualatex',
						-- '-outdir=build',
						'-latexoption=-cnf-line=shell_escape_commands=${shell_escape_commands},dot,neato,texcount',
						'%f'
					},
					outputDirectory = 'build',
					onSave = true,
				},
				forwardSearch = {
					executable = 'okular',
					args = { '%p' },
				},
			},
		},
	}
	lspconfig.omnisharp.setup{
		cmd = { 'omnisharp' },
	}
	lspconfig.rust_analyzer.setup{}
	lspconfig.hls.setup{}
	-- lspconfig.jdtls.setup{}
end)

Plug 'ray-x/lsp_signature.nvim'
table.insert(after, function()
	require'lsp_signature'.setup{
		bind = true,
		hint_enable = false,
		handler_opts = {
			border = floatBorder,
		},
	}
end)

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/cmp-omni'
Plug 'hrsh7th/nvim-cmp'
table.insert(after, function()
	local cmp = require 'cmp'

	cmp.setup({
		snippet = {
			expand = function(args) vim.fn["vsnip#anonymous"](args.body) end,
		},
		window = {
			-- completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered{border = floatBorder},
		},
		mapping = cmp.mapping.preset.insert({
			['<C-b>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-Space>'] = cmp.mapping.complete(),
			['<C-e>'] = cmp.mapping.abort(),
			['<CR>'] = cmp.mapping.confirm({ select = false }),
		}),
		sources = cmp.config.sources({
			{ name = 'nvim_lsp' },
			{ name = 'vsnip' },
			-- { name = 'omni' },
		}, {
			{ name = 'path' },
			{ name = 'buffer' },
		})
	})

	-- -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
	-- cmp.setup.cmdline({ '/', '?' }, {
	-- 	mapping = cmp.mapping.preset.cmdline(),
	-- 	sources = {
	-- 		{ name = 'buffer' }
	-- 	}
	-- })

	-- -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
	-- cmp.setup.cmdline(':', {
	-- 	mapping = cmp.mapping.preset.cmdline(),
	-- 	sources = cmp.config.sources({
	-- 		{ name = 'path' }
	-- 	}, {
	-- 		{ name = 'cmdline' }
	-- 	})
	-- })

	-- require'cmp'.setup({
	-- 	enabled = true,
	-- 	autocomplete = true,
	-- 	documentation = {
	-- 		border = floatBorder,
	-- 	},
	-- 	source = {
	-- 		path = true,
	-- 		buffer = true,
	-- 		nvim_lsp = true,
	-- 		vsnip = true,
	-- 	},
	-- })
	-- vim.keymap.set('i', '<CR>', "compe#confirm('<CR>')", { expr = true, replace_keycodes = false })
end)

Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
vim.g.vsnip_snippet_dir = vim.fn.stdpath('config')..'/vsnip'
vim.keymap.set({'i', 's'}, '<Tab>',   "vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<Tab>'", { expr = true, remap = true, replace_keycodes = false });
vim.keymap.set({'i', 's'}, '<S-Tab>', "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<Tab>'", { expr = true, remap = true, replace_keycodes = false });

Plug 'qpkorr/vim-renamer'
vim.g.RenamerSupportColonWToRename = 1

Plug 'peterhoeg/vim-qml'

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
-- Plug 'nvim-treesitter/playground'
table.insert(after, function()
	require'nvim-treesitter.configs'.setup {
		ensure_installed = { 'cpp', 'html', 'css', 'javascript' },
		highlight = {
			enable = true,
		},
		indent = {
			enable = false,
			-- disable = { 'python', 'c', 'cpp' },
		},
	}
end)

Plug 'PeterRincker/vim-argumentative'

Plug 'vito-c/jq.vim'

Plug 'tpope/vim-surround'

Plug 'mattn/emmet-vim'
vim.g.user_emmet_leader_key = '<C-S>'

Plug 'mfussenegger/nvim-jdtls'
autocmd('FileType', { pattern = 'java', callback = function()
	require'jdtls'.start_or_attach{
		cmd = {'jdtls'},
		on_attach = require'lspconfig'.util.default_config.on_attach
	}
end})

Plug 'mikebentley15/vim-pio'

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
