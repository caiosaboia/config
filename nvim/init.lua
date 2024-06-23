-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
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

vim.opt.relativenumber = false

if vim.g.neovide then
	vim.g.neovide_refresh_rate=60
	vim.g.neovide_transparency=0.9
	vim.g.neovide_floating_blur_amount_x = 2.0
	vim.g.neovide_floating_blur_amount_y = 2.0
	vim.g.neovide_scroll_animation_length = 0.1
	vim.g.neovide_cursor_trail_size=0.8
	-- vim.opt.guifont= { 'FiraCode Nerd Font', 'DejaVuSansM Nerd Font', 'Fira Code', ':h11' }
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

require('lualine').setup({
	options = {
		theme = 'horizon',
	},
	sections = {
		lualine_x = {LspIcon,'fileformat', 'filetype'},
	},
})
