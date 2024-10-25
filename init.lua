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

if vim.g.neovide then
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_transparency = 0.9
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.8
  -- vim.opt.guifont= {'MesloLGSDZ Nerd Font'}
  vim.keymap.set('n', '<c-s-v>', '"+p')
  vim.keymap.set('i', '<c-s-v>', '<c-r><c-o>+')

  local default_font = vim.o.guifont
  vim.keymap.set({ 'n', 'i' }, '<c-=>', function()
    local fsize = vim.o.guifont:match('^.*:h([^:]*).*$')
    fsize = tonumber(fsize) + 1
    local gfont = vim.o.guifont:gsub(':h([^:]*)', ':h' .. fsize)
    vim.o.guifont = gfont
  end)

  vim.keymap.set({ 'n', 'i' }, '<c-->', function()
    local fsize = vim.o.guifont:match('^.*:h([^:]*).*$')
    fsize = tonumber(fsize) - 1
    local gfont = vim.o.guifont:gsub(':h([^:]*)', ':h' .. fsize)
    vim.o.guifont = gfont
  end)
  vim.keymap.set({ 'n', 'i' }, '<c-0>', function()
    vim.o.guifont = default_font
  end)
end


require('nvim-web-devicons').setup {
  override_by_extension = {
    ["qmd"] = {
      icon = "",
      color = "#42f2f5",
      name = "quarto"
    }
  },
}

require('lsp-progress').setup({})


local function LspIcon()
  return require("lsp-progress").progress({
    format = function(messages)
      local active_clients = vim.lsp.get_active_clients()
      local client_count = #active_clients
      if #messages > 0 then
        return " LSP:"
            .. " "
            .. table.concat(messages, " ")
      end
      if #active_clients <= 0 then
        return " LSP:"
      else
        local client_names = {}
        for i, client in ipairs(active_clients) do
          if client and client.name ~= "" then
            table.insert(client_names, "" .. client.name .. "")
          end
        end
        return " LSP:"
            .. " "
            .. table.concat(client_names, " ")
      end
    end,
  })
end



local virtual_env = function()
  -- only show virtual env for Python
  if vim.bo.filetype ~= 'python' then
    return ""
  end

  local conda_env = os.getenv('CONDA_DEFAULT_ENV')
  local venv_path = os.getenv('VIRTUAL_ENV')

  if venv_path == nil then
    if conda_env == nil then
      return ""
    else
      return string.format("  %s (conda)", conda_env)
    end
  else
    local venv_name = vim.fn.fnamemodify(venv_path, ':t')
    return string.format("  %s (venv)", venv_name)
  end
end



require('lualine').setup({
  options = {
    theme = 'horizon',
  },
  sections = {
    lualine_x = { virtual_env, LspIcon, 'fileformat', 'filetype' },
  },
})

-- Define o bloco de texto como uma tabela de linhas
local quarto_header = {
  "---",
  'title: "Exemplo de Regressão Linear Simples"',
  "# author: \"\" #if necessary",
  "# date: \"dd/mm/aaaa\" #if necessary",
  "format:", 
  "  html:",
  "    toc: true",
  "    number-sections: true",
  "    # toc-location: right-body",
  "    code-fold: false",
  "    # css: styles.css #if necessary",
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
  "  #   name: \"xpython\"",
  "  #   language: \"python\"",
  "  #   display_name: \"Python 3.7 (XPython)\"",
  "",
  "#R",
  "# knitr:",
  "#   opts_chunk:", 
  "#     collapse: true",
  "#     comment: \"#>\"",
  "#     R.options:",
  "#       knitr.graphics.auto_pdf: true",
  "",
  "# engine: julia # for more aplicatoins use quarto.org or :QuartoHelp Julia",
  "---",
}

vim.keymap.set('n', ' rjb', function()
  vim.api.nvim_put(quarto_header, 'l', true, true)
end, {desc = "Formato Base Quarto", noremap = true, silent = true })
vim.keymap.set("n", " rji", 'o```{python}\n```<Esc>O', { desc = "Celula Python" , noremap = true, silent = true})
vim.keymap.set("n", " rjr", 'o```{r}\n```<Esc>O', { desc = "Celular R" , noremap = true, silent = true})
vim.keymap.set("n", " rfa", ':QuartoActivate<CR>', { desc = "Quarto Activate" , noremap = true, silent = true})
vim.keymap.set("n", " rfp", ':QuartoPreview<CR>', { desc = "Quarto Preview" , noremap = true, silent = true})
vim.keymap.set("n", " rfc", ':QuartoClosePreview<CR>', { desc = "Quarto Close Preview" , noremap = true, silent = true})



local runner = require("quarto.runner")
vim.keymap.set("n", " rc", runner.run_cell, {desc = "Run Cell", silent = true})
vim.keymap.set("n", " ra", runner.run_above, {desc = "Run Cell and Above", silent = true})
vim.keymap.set("n", " rA", runner.run_all, {desc = "Run All Cells", silent = true})
vim.keymap.set("n", " rl", runner.run_line, {desc = "Run Line", silent = true})
vim.keymap.set("n", " r", runner.run_range, {desc = "Cells", silent = true})
vim.keymap.set("n", " rRA", function ()
  runner.run_all(true)
end, {desc = "Run All Cells of All Languages", silent = true})

require('quarto').setup{
      debug = false,
      closePreviewOnExit = true,
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "r", "python", "julia", "bash", "html" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = false,
        default_method = nil, -- 'molten' or 'slime'
        ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
                         -- Takes precedence over `default_method`
        never_run = { "yaml" }, -- filetypes which are never sent to a code runner
      },
    }







