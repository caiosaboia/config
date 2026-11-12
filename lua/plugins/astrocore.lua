-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = false, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        txt = "markdown",
      },
    },
    -- Autocmds gerenciados pelo AstroCore
    autocmds = {
      uv_auto_venv = {
        {
          event = { "BufEnter", "DirChanged" },
          desc = "Auto-detect and set VIRTUAL_ENV for Astral UV",
          callback = function()
            local ok, molten_uv = pcall(require, "molten.uv")
            if ok then
              local root = molten_uv.find_project_root()
              if root then
                local venv_path = root .. "/.venv"
                local uv_loop = vim.uv or vim.loop
                if uv_loop.fs_stat(venv_path) then
                  local norm_venv = vim.fs.normalize(venv_path)
                  if vim.env.VIRTUAL_ENV ~= norm_venv then
                    vim.env.VIRTUAL_ENV = norm_venv
                    local scripts = norm_venv .. "/Scripts"
                    if uv_loop.fs_stat(scripts) and not vim.env.PATH:find(scripts, 1, true) then
                      vim.env.PATH = scripts .. ";" .. vim.env.PATH
                    end
                  end
                end
              end
            end
          end,
        },
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- sets vim.opt.wrap
        clipboard = "unnamedplus", -- sync with system clipboard
      },
      g = { -- vim.g.<key>
        python3_host_prog = "C:/Users/cocad/miniforge3/python.exe",
        clipboard = {
          name = "win32yank",
          copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
          },
          paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
          },
          cache_enabled = 0,
        },
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- Molten keymaps
        ["<Leader>m"] = { desc = "󰘦 Molten" },
        ["<Leader>mu"] = { "<Cmd>MoltenInitUV<CR>", desc = "Inicializar com UV (Auto-Kernel)" },
        ["<Leader>mi"] = { "<Cmd>MoltenInit python3<CR>", desc = "Inicializar Molten (python3)" },
        ["<Leader>me"] = { "<Cmd>MoltenEvaluateLine<CR>", desc = "Executar linha" },
        ["<Leader>mc"] = { "<Cmd>MoltenRunCell<CR>", desc = "Executar celula atual" },
        ["<Leader>mn"] = { "<Cmd>MoltenRunAndAdvance<CR>", desc = "Executar celula e avancar" },
        ["<Leader>mj"] = { "<Cmd>MoltenRunNext<CR>", desc = "Pular para proxima celula e executar" },
        ["<Leader>ma"] = { "<Cmd>MoltenRunAll<CR>", desc = "Executar todas as celulas" },
        ["<Leader>mca"] = { "<Cmd>MoltenRunAbove<CR>", desc = "Executar celulas acima" },
        ["<Leader>mcb"] = { "<Cmd>MoltenRunBelow<CR>", desc = "Executar celulas abaixo" },
        ["<Leader>mr"] = { "<Cmd>MoltenReevaluateCell<CR>", desc = "Re-executar celula (Molten)" },
        ["<Leader>mo"] = { "<Cmd>MoltenOutputToggle<CR>", desc = "Alternar output flutuante" },
        ["<Leader>mh"] = { "<Cmd>MoltenHideOutput<CR>", desc = "Ocultar output flutuante" },
        ["<Leader>mp"] = { "<Cmd>MoltenImagePopup<CR>", desc = "Popup de imagem (Pillow)" },
        ["]c"] = { "<Cmd>MoltenCellNext<CR>", desc = "Proxima celula (# %% ou fence)" },
        ["[c"] = { "<Cmd>MoltenCellPrev<CR>", desc = "Celula anterior (# %% ou fence)" },
        ["<S-CR>"] = { "<Cmd>MoltenRunAndAdvance<CR>", desc = "Executar celula e avancar" },
        ["<C-CR>"] = { "<Cmd>MoltenRunCell<CR>", desc = "Executar celula atual" },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      v = {
        ["<Leader>m"] = { desc = "󰘦 Molten" },
        ["<Leader>me"] = { ":<C-u>MoltenEvaluateVisual<CR>", desc = "Executar selecao visual" },
        ["<Leader>mr"] = { ":<C-u>MoltenEvaluateVisual<CR>", desc = "Executar selecao visual" },
      },
    },
  },
}
