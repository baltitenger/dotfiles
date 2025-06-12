local autocmd = vim.api.nvim_create_autocmd
function autocmd(opts)
	local ev = opts[1]
	local pat = opts[2]
	opts[1] = nil
	opts[2] = nil
	opts.pattern = pat
	vim.api.nvim_create_autocmd(ev, opts)
end

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 6
vim.opt.lazyredraw = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.list = true
vim.opt.listchars = { tab = '  ', extends = '>', precedes = '<', trail = '·', nbsp = '␣' }
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
vim.opt.diffopt = { 'filler', 'iwhite', 'closeoff', 'internal', 'indent-heuristic', 'linematch:60' }
vim.opt.wildmode = { 'longest:full', 'full' }
vim.opt.inccommand = 'nosplit'
if vim.env.SSH_TTY == nil then
	vim.opt.clipboard = 'unnamed'
end

autocmd{'BufEnter', '*.sage', command = [[setl ft=python]] }

autocmd{'FileType', 'tex', command = [[setl spell]] }
autocmd{'FileType', 'markdown', command = [[
	setlocal tw=80
	compiler markdown
]]}
autocmd{'FileType', 'cs', command = [[compiler dotnet]]}
autocmd{'FileType', 'haskell', command = [[setl ts=8 sw=2 et]]}
autocmd{'FileType', {'c', 'cpp', 'cs'}, command = [[setl cms=//\ %s]] }

autocmd{'FileType', callback = function(_)
	local cms = vim.bo.commentstring
	cms = cms:gsub('(%S)(%%s)', '%1 %2')
	cms = cms:gsub('(%%s)(%S)', '%1 %2')
	vim.bo.commentstring = cms
end}

autocmd{'BufNewFile', nested = true, callback = function(info)
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
end}

vim.cmd[==[
au BufWritePre /tmp/* setlocal undodir=.
autocmd BufRead * autocmd FileType <buffer> ++once if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif

com! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
com! -bang W lua SudoWrite('<bang>' == '!')

colorscheme vim
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

vim.diagnostic.config({ virtual_text = true })
vim.keymap.set('n', 'gK', function()
	local old = vim.diagnostic.config()
	vim.diagnostic.config({
		virtual_lines = not old.virtual_lines,
		virtual_text = not old.virtual_text,
	})
end, { desc = 'Toggle diagnostic virtual_{lines,text}' })

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

function ToggleBraces()
	local l = vim.api.nvim_win_get_cursor(0)[1] - 2
	local lines = vim.api.nvim_buf_get_lines(0, l, l+3, true)
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

vim.keymap.set('n', '<Leader>/', '<Cmd>noh<CR>')
vim.keymap.set('n', '<M-u>', '<Cmd>noh<CR>')
vim.keymap.set('n', 'Y', 'y$')
vim.keymap.set('n', 'gb', GitBlame)
-- vim.keymap.set('v', '<Leader>w', VisualWc)
vim.keymap.set('v', '<Leader>w', '<Cmd>lua VisualWc()<CR>') -- should convert to an operator probably
vim.keymap.set('i', '<C-BS>', '<C-W>')
vim.keymap.set('n', '<M-h>', '<C-W>h')
vim.keymap.set('n', '<M-j>', '<C-W>j')
vim.keymap.set('n', '<M-k>', '<C-W>k')
vim.keymap.set('n', '<M-l>', '<C-W>l')
vim.keymap.set('n', 'É', ':')
vim.keymap.set('n', 'gs', ToggleBraces)
vim.keymap.set('n', '<C-/>', 'gcc', {remap=true})
vim.keymap.set('v', '<C-/>', 'gc',  {remap=true})

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) and executable('git') then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system{ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end
vim.opt.rtp:prepend(lazypath)

require'lazy'.setup({
	{
		'junegunn/vim-easy-align',
		keys = {
			{ 'ga', '<Plug>(EasyAlign)', mode = {'x', 'n'}},
		},
		config = function()
			local delims = {
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
			if vim.bo.filetype == 'tex' then
				delims['\\'] = {
					pattern         = [[\\\\]],
					delimiter_align = 'center',
				}
			end
			vim.g.easy_align_delimiters = delims
		end,
	},
	{
		'neovim/nvim-lspconfig',
		config = function()
			local lspconfig = require 'lspconfig'

			vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = floatBorder,
			})

			-- silent "unused" warnings
			local test_ns = vim.api.nvim_create_namespace('test')
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

      local caps = vim.lsp.protocol.make_client_capabilities()
      caps = vim.tbl_deep_extend('force', caps, require('cmp_nvim_lsp').default_capabilities())
			lspconfig.util.default_config.capabilities = caps

      vim.api.nvim_create_autocmd('LspAttach', { callback = function(ev)
				local map = function(mode, keys, func)
					vim.keymap.set(mode, keys, func, { buffer = ev.buf })
				end
				map('n', 'gd',    vim.lsp.buf.definition)
				map('n', 'gr',    vim.lsp.buf.references)
				map('n', 'gI',    vim.lsp.buf.implementation)
				map('n', ' D',    vim.lsp.buf.type_definition)
				map('n', ' r',    vim.lsp.buf.rename)
				map('n', ' a',    vim.lsp.buf.code_action)
				map('n', 'gD',    vim.lsp.buf.declaration)
				map('n', '<C-k>', vim.lsp.buf.signature_help)

				-- Set some keybinds conditional on server capabilities
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client.server_capabilities.documentFormattingProvider then
					map('n', ' f', function() vim.lsp.buf.format{} end)
				end
				if client.server_capabilities.documentRangeFormattingProvider then
					map('v', ' f', function() vim.lsp.buf.format{}; vim.api.nvim_input('<Esc>') end)
				end

				-- keep vim internal formatter
				vim.bo[ev.buf].formatexpr = vim.go.formatexpr
			end})

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
			lspconfig.ts_ls.setup{}
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
								'-latexoption=-cnf-line=shell_escape_commands=${shell_escape_commands},dot,neato,texcount,latexminted',
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
			-- lspconfig.omnisharp.setup{
			-- 	cmd = { 'omnisharp' },
			-- }
			-- lspconfig.rust_analyzer.setup{}
			lspconfig.hls.setup{}
			-- lspconfig.jdtls.setup{}
			-- lspconfig.bashls.setup{}
			lspconfig.gdscript.setup{}
			lspconfig.zls.setup{}
			lspconfig.gopls.setup{}
		end,
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-nvim-lsp',
			'saadparwaiz1/cmp_luasnip',
			{
				'L3MON4D3/LuaSnip',
				version = 'v2.*',
				build = 'make install_jsregexp',
			},
			-- 'hrsh7th/cmp-nvim-lsp-signature-help',
		},
		opts = function()
			local cmp = require'cmp'
			local luasnip = require'luasnip'
			return {
				snippet = {
					expand = function(args) luasnip.lsp_expand(args.body) end,
				},
				window = {
					documentation = {border = floatBorder},
				},
				mapping = cmp.mapping.preset.insert({
					['<C-u>'] = cmp.mapping.scroll_docs(-4),
					['<C-d>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<CR>'] = cmp.mapping.confirm({ select = false }),
					['<Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { 'i', 's' }),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					-- { name = 'nvim_lsp_signature_help' },
				}, {
					{ name = 'path' },
					{ name = 'buffer' },
				})
			}
		end,
	},
	{
		'qpkorr/vim-renamer',
		cmd = 'Renamer',
		config = function()
			vim.g.RenamerSupportColonWToRename = 1
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function() require'nvim-treesitter.configs'.setup {
			ensure_installed = { 'cpp', 'html', 'css', 'javascript' },
			highlight = { enable = true },
			indent = { enable = false },
		} end
	},
	{
		'mfussenegger/nvim-jdtls',
		ft = 'java',
		config = function()
			local attach = function() require'jdtls'.start_or_attach {
				cmd = {'jdtls'},
				on_attach = require'lspconfig'.util.default_config.on_attach,
				root_dir = vim.fs.root(0, {'.git', 'mvnw', 'gradlew'})
			} end
			attach()
			autocmd{'FileType', 'java', callback = attach }
		end,
	},
	{
		'ray-x/lsp_signature.nvim',
		opts = {
			bind = true,
			hint_enable = false,
			handler_opts = {
				border = floatBorder,
			},
		},
	},
	'PeterRincker/vim-argumentative',
	'tpope/vim-surround',
	'peterhoeg/vim-qml',
	'vito-c/jq.vim',
	'mikebentley15/vim-pio',
	'HiPhish/info.vim',
	-- { 'RaafatTurki/hex.nvim', opts = {} },
	-- 'mattn/emmet-vim',
}, {
	ui = {
		icons = {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
