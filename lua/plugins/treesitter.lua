-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- Adicionei o bash aqui para ele gerenciar a instalação corretamente
    ensure_installed = {
      "lua",
      "vim",
      "python",
      "sql",
      "bash",
      "markdown",
      "markdown_inline", -- Útil para ver o help do nvim melhor
    },
    -- No Windows, é melhor deixar o sync_install como false
    sync_install = false,
    -- auto_install tenta instalar quando você entra num arquivo novo.
    -- Se der erro de "file in use", mude para false e instale manualmente com :TSInstall
    auto_install = true,
  },
}
