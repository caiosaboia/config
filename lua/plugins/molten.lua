---@type LazySpec
return {
  {
    "benlubas/molten-nvim",
    init = function()
      -- Otimizacoes para Windows e terminal noctty
      vim.g.molten_image_provider = "none"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false -- Desativado para nao colar nem pular na linha vizinha
      vim.g.molten_output_virt_lines = true -- Cria espaco com linhas virtuais para nao cobrir codigo
      vim.g.molten_wrap_output = true
      vim.g.molten_auto_image_popup = true
      vim.g.molten_use_border_highlights = true
      vim.g.molten_output_win_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }

      -- Destaque e estilizacao visual para distanciar o texto virtual do codigo
      vim.api.nvim_set_hl(0, "MoltenVirtualText", { link = "DiagnosticVirtualTextInfo" })

      -- Registra comando para inicializacao automatica com Astral UV
      vim.api.nvim_create_user_command("MoltenInitUV", function()
        require("molten.uv").init_uv_kernel()
      end, { desc = "Inicializa o kernel Jupyter do projeto UV atual com verificacao de dependencias" })
    end,
  },
  {
    "rebelot/heirline.nvim",
    optional = true,
    opts = function(_, opts)
      -- Protege componentes do molten com pcall para evitar crash de channel rplugin
      if opts.statusline then
        for _, comp in ipairs(opts.statusline) do
          if type(comp) == "table" then
            if comp.condition then
              local orig_cond = comp.condition
              comp.condition = function(...)
                local ok, res = pcall(orig_cond, ...)
                return ok and res or false
              end
            end
            if comp.provider and type(comp.provider) == "function" then
              local orig_prov = comp.provider
              comp.provider = function(...)
                local ok, res = pcall(orig_prov, ...)
                return ok and res or ""
              end
            end
          end
        end
      end
    end,
  },
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
      style = "hydrogen",
      output_extension = "auto",
      force_ft = "python",
    },
    config = function(_, opts)
      require("jupytext").setup(opts)
    end,
  },
}
