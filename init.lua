-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
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
-- vim.diagnostic.config {
--   virtual_text = false,
-- }
-- vim.g.slime_target = "kitty"
-- vim.g.clipboard = "clip"

-- Neovide {{
if vim.g.neovide then
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
-- }}
local wk = require "which-key"
wk.add {
  { "<leader>ic", group = "Copilot" },
  { "<leader>  g", group = "Gemini" },
  { "<leader>i", group = " IA" },
}
-- Copilot Setup {{{
-- use o alt + l no Normal mode para aceitar a sugestão
vim.keymap.set("n", "<leader>ice", function()
  require("copilot.command").enable()
  require("snacks").notify.info("Copilot Habilitado", {
    title = "GitHub Copilot",
    icon = "",
  })
end, { desc = "Enable Copilot" })
vim.keymap.set("n", "<leader>icd", function()
  require("copilot.command").disable()
  require("snacks").notify.warn("Copilot Desabilitado", {
    title = "GitHub Copilot",
    icon = "",
  })
end, { desc = "Disable Copilot" })
-- }}}

-- Gemini Setup {{{

-- }}}
