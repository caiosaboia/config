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

      -- Comandos do Molten Runner
      local runner = function()
        return require("molten.runner")
      end

      vim.api.nvim_create_user_command("MoltenRunCell", function()
        runner().run_cell()
      end, { desc = "Executa a celula atual sob o cursor" })

      vim.api.nvim_create_user_command("MoltenRunAndAdvance", function()
        runner().run_cell_and_advance()
      end, { desc = "Executa a celula atual e avanca para a proxima" })

      vim.api.nvim_create_user_command("MoltenRunNext", function()
        runner().run_next_cell()
      end, { desc = "Avanca para a proxima celula e a executa" })

      vim.api.nvim_create_user_command("MoltenRunAll", function()
        runner().run_all()
      end, { desc = "Executa todas as celulas do buffer" })

      vim.api.nvim_create_user_command("MoltenRunAbove", function()
        runner().run_above()
      end, { desc = "Executa todas as celulas ate a celula atual" })

      vim.api.nvim_create_user_command("MoltenRunBelow", function()
        runner().run_below()
      end, { desc = "Executa da celula atual ate a ultima celula" })

      vim.api.nvim_create_user_command("MoltenCellNext", function()
        runner().jump_next()
      end, { desc = "Pula para a proxima celula" })

      vim.api.nvim_create_user_command("MoltenCellPrev", function()
        runner().jump_prev()
      end, { desc = "Pula para a celula anterior" })
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
