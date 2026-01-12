-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo(
    { { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } },
    true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

vim.opt.relativenumber = true
vim.o.wrap = true
vim.o.cmdheight = 1
vim.g.molten_auto_open_output = false
vim.g.molten_image_provider = "image.nvim"
vim.g.molten_wrap_output = true
vim.g.molten_virt_text_output = true
vim.g.molten_virt_lines_off_by_1 = true
vim.diagnostic.config {
  virtual_text = false,
}
-- vim.g.slime_target = "kitty"
-- vim.g.clipboard = "clip"

if vim.g.neovide then
  vim.cmd ":colorscheme material-darker"
  vim.o.title = true
  vim.o.titlestring = "Neovide"
  vim.o.cmdheight = 0
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_opacity = 0.9
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_scroll_animation_length = 0.3
  vim.g.neovide_cursor_trail_size = 0.8
  vim.opt.guifont = { "MesloLGLDZ Nerd Font:h08" }
  vim.keymap.set("n", "<c-s-v>", '"+p')
  vim.keymap.set("i", "<c-s-v>", "<c-r><c-o>+")

  local default_font = vim.o.guifont
  vim.keymap.set({ "n", "i" }, "<c-=>", function()
    local fsize = vim.o.guifont:match "^.*:h([^:]*).*$"
    fsize = tonumber(fsize) + 1
    local gfont = vim.o.guifont:gsub(":h([^:]*)", ":h" .. fsize)
    vim.o.guifont = gfont
  end)

  vim.keymap.set({ "n", "i" }, "<c-->", function()
    local fsize = vim.o.guifont:match "^.*:h([^:]*).*$"
    fsize = tonumber(fsize) - 1
    local gfont = vim.o.guifont:gsub(":h([^:]*)", ":h" .. fsize)
    vim.o.guifont = gfont
  end)
  vim.keymap.set({ "n", "i" }, "<c-0>", function() vim.o.guifont = default_font end)
end

require("toggleterm").setup {
  shell = "pwsh.exe",
}

require("nvim-web-devicons").set_icon {
  qmd = {
    icon = "󰐗", -- Altere o ícone para outro de sua preferência
    color = "#558ADF", -- Cor do ícone
    cterm_color = "173",
    name = "Quarto",
  },
}

-- require("lualine").setup {
--   options = {
--     component_separators = { left = "", right = "" },
--     section_separators = { left = "", right = "" },
--   },
--   sections = {
--     lualine_a = { "mode" },
--     lualine_b = { "branch", "diff", "diagnostics" },
--     lualine_c = { "filetype" },
--     lualine_x = { "lsp_status" },
--     lualine_y = {},
--     lualine_z = { "mode" },
--   },
--   extensions = {
--     "aerial",
--     "assistant",
--     "avante",
--     "chadtree",
--     "ctrlspace",
--     "fern",
--     "fugitive",
--     "fzf",
--     "lazy",
--     "man",
--     "mason",
--     "mundo",
--     "neo-tree",
--     "nerdtree",
--     "nvim-dap-ui",
--     "nvim-tree",
--     "oil",
--     "overseer",
--     "quickfix",
--     "symbols-outline",
--     "toggleterm",
--     "trouble",
--   },
-- }

-- Define o bloco de texto como uma tabela de linhas
local quarto_header = {
  "---",
  '# title: "title"',
  '# subtitle: " subtitulo"',
  '# author: "seu nome"',
  '# date: "dd/mm/aaaa" #if necessary',
  "format:",
  "  html:",
  "    toc: false",
  "    number-sections: true",
  "    # toc-location: right-body",
  "    code-fold: false",
  "    # css: styles.css #if necessary",
  "    math: mathjax",
  "",
  "  pdf:",
  "    number-sections: true",
  "    toc: true",
  "    keep_tex: true",
  "",
  "latex-engine: xelatex",
  "",
  "header-includes:",
  "  - \\usepackage{amsmath}",
  "  - \\usepackage{amsfonts}",
  "  - \\usepackage{amssymb}",
  "  - \\usepackage{listings}",
  "",
  "execute:",
  "  cache: true",
  "  enabled: true",
  "  freeze: true #can be use 'false' or auto",
  "  # daemon: false #default is 300, but can use boleean values too ",
  "",
  "#python",
  "jupyter: python3 #can be use for Julia too",
  "  # or can be use something like this:",
  "  # kernelspec:",
  '  #   name: "xpython"',
  '  #   language: "python"',
  '  #   display_name: "Python 3.7 (XPython)"',
  "",
  "#R",
  "knitr:",
  "  opts_chunk:",
  "    collapse: true",
  '    comment: ">>"',
  "    R.options:",
  "      knitr.graphics.auto_pdf: true",
  "",
  "# engine: julia # for more aplicatoins use quarto.org or :QuartoHelp Julia",
  "---",
}

vim.keymap.set(
  "n",
  " rjb",
  function() vim.api.nvim_put(quarto_header, "l", true, true) end,
  { desc = "Formato Base Quarto", noremap = true, silent = true }
)
vim.keymap.set("n", " rji", "o```{python}\n```<Esc>O", { desc = "Celula Python", noremap = true, silent = true })
vim.keymap.set("n", " rjr", "o```{r}\n```<Esc>O", { desc = "Celular R", noremap = true, silent = true })
vim.keymap.set("n", " rfa", ":QuartoActivate<CR>", { desc = "Quarto Activate", noremap = true, silent = true })
vim.keymap.set("n", " rfp", ":QuartoPreview<CR>", { desc = "Quarto Preview", noremap = true, silent = true })
vim.keymap.set("n", " rfc", ":QuartoClosePreview<CR>", { desc = "Quarto Close Preview", noremap = true, silent = true })

-- require('quarto').setup{
--       debug = false,
--       closePreviewOnExit = true,
--       lspFeatures = {
--         enabled = true,
--         chunks = "curly",
--         languages = { "r", "python", "julia", "bash", "html", "latex", "markdown" },
--         diagnostics = {
--           enabled = true,
--           triggers = { "BufWritePost" },
--         },
--         completion = {
--           enabled = true,
--         },
--       },
--       codeRunner = {
--         enabled = false,
--         default_method = 'molten', -- 'molten' or 'slime'
--         ft_runners = {python = "molten", r = "molten"}, -- filetype to runner, ie. `{ python = "molten" }`.
--                          -- Takes precedence over `default_method`
--         never_run = { "yaml" }, -- filetypes which are never sent to a code runner
--       },
--     }
--
-- local runner = require "quarto.runner"
-- vim.keymap.set("n", " rc", runner.run_cell, { desc = "Run Cell", silent = true })
-- vim.keymap.set("n", " ra", runner.run_above, { desc = "Run Cell and Above", silent = true })
-- vim.keymap.set("n", " rA", runner.run_all, { desc = "Run All Cells", silent = true })
-- vim.keymap.set("n", " rl", runner.run_line, { desc = "Run Line", silent = true })
-- vim.keymap.set("n", " r", runner.run_range, { desc = "Cells", silent = true })
-- vim.keymap.set(
--   "n",
--   " rRA",
--   function() runner.run_all(true) end,
--   { desc = "Run All Cells of All Languages", silent = true }
-- )

local alpha = require "alpha"
local dashboard = require "alpha.themes.dashboard"
-- local theta = require "alpha.themes.theta"
-- Cabeçalho (ASCII art) com cores personalizadas
dashboard.section.header.val = {
  -- [[    ___         __             _   __      _         ]],
  -- [[   /   |  _____/ /__________  / | / /   __(_)___ ___ ]],
  -- [[  / /| | / ___/ __/ ___/ __ \/  |/ / | / / / __ `__ \]],
  -- [[ / ___ |(__  ) /_/ /  / /_/ / /|  /| |/ / / / / / / /]],
  -- [[/_/  |_/____/\__/_/   \____/_/ |_/ |___/_/_/ /_/ /_/ ]],

  -- [[                                                  :                                                        ]],
  -- [[                         .                       t#,     L.                                                ]],
  -- [[                        ;W          j.          ;##W.    EW:        ,ft            t                       ]],
  -- [[             ..        f#E GEEEEEEELEW,        :#L:WE    E##;       t#E            Ej            ..       :]],
  -- [[            ;W,      .E#f  ,;;L#K;;.E##j      .KG  ,#D   E###t      t#E t      .DD.E#,          ,W,     .Et]],
  -- [[           j##,     iWW;      t#E   E###D.    EE    ;#f  E#fE#f     t#E EK:   ,WK. E#t         t##,    ,W#t]],
  -- [[          G###,    L##Lffi    t#E   E#jG#W;  f#.     t#i E#t D#G    t#E E#t  i#D   E#t        L###,   j###t]],
  -- [[        :E####,   tLLG##L     t#E   E#t t##f :#G     GK  E#t  f#E.  t#E E#t j#f    E#t      .E#j##,  G#fE#t]],
  -- [[       ;W#DG##,     ,W#i      t#E   E#t  :K#E:;#L   LW.  E#t   t#K: t#E E#tL#i     E#t     ;WW; ##,:K#i E#t]],
  -- [[      j###DW##,    j#E.       t#E   E#KDDDD###it#f f#:   E#t    ;#W,t#E E#WW,      E#t    j#E.  ##f#W,  E#t]],
  -- [[     G##i,,G##,  .D#j         t#E   E#f,t#Wi,,, f#D#;    E#t     :K#D#E E#K:       E#t  .D#L    ###K:   E#t]],
  -- [[   :K#K:   L##, ,WK,          t#E   E#t  ;#W:    G#t     E#t      .E##E ED.        E#t :K#t     ##D.    E#t]],
  -- [[  ;##D.    L##, EG.            fE   DWi   ,KK:    t      ..         G#E t          E#t ...      #G      .. ]],
  -- [[  ,,,      .,,  ,               :                                    fE            ,;.          j          ]],
  -- [[                                                                      ,                                    ]],
}
dashboard.section.footer.val = {
  "If you have ghost, you have everything.",
}
dashboard.section.header.opts = {
  hl = "DashboardHeader", -- Grupo de destaque para o cabeçalho
  position = "center", -- Posição do cabeçalho
}
dashboard.section.buttons.opts = {
  hl = "DashboardButtons", -- Grupo de destaque para os botões
  hl_shortcut = "DashboardShortcut", -- Cor do atalho (tecla)
}
dashboard.section.footer.opts = {
  hl = "DashboardFooter", -- Grupo de destaque para o rodapé
  position = "center", -- Posição do cabeçalho
}
vim.cmd [[
    hi DashboardHeader guifg=#FA8072 guibg=NONE
    hi DashboardButtons guifg=#8be9fd guibg=NONE
    hi DashboardShortcut guifg=#50fa7b guibg=NONE
    hi DashboardFooter guifg=#FF0000 guibg=NONE
]]

alpha.setup(dashboard.config)

-- Markdown Preview Setup
vim.g.mkdp_auto_start = 1
vim.g.mkdp_auto_close = 1

require("render-markdown").setup {
  file_types = { "markdown", "quarto" },
  sign = {
    enabled = true,
  },
  indent = { enabled = true },
  dash = {
    enabled = true,
    icon = "─",
    width = "full",
    -- highlight = "RenderMarkdownDash",
  },
  heading = {
    enabled = true,
    sign = false,
    position = "inline",
    -- icons = { "󰼏 ", "󰎨 ", "󰼑 ", "󰎲 ", "󰼓 ", "󰎴 " },
    signs = { "󰫎 " },
    width = "block",
    left_margin = 0,
    left_pad = 0,
    right_pad = 0,
    min_width = 0,
    border = false,
    border_virtual = false,
    border_prefix = false,
    above = "▄",
    below = "▀",
    backgrounds = {
      "RenderMarkdownH1Bg",
      "RenderMarkdownH3Bg",
      "RenderMarkdownH1Bg",
      "RenderMarkdownH3Bg",
      "RenderMarkdownH1Bg",
      "RenderMarkdownH3Bg",
    },
    foregrounds = {
      "RenderMarkdownH3",
      "RenderMarkdownH2",
      "RenderMarkdownH3",
      "RenderMarkdownH4",
      "RenderMarkdownH5",
      "RenderMarkdownH6",
    },
  },
}

require("lspconfig").pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = { "E501" },
          maxLineLength = 100,
        },
        ruff = {
          enabled = true,
        },
      },
    },
  },
}
