return {
  "github/copilot.vim",
  vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', {
    expr = true,
    replace_keycodes = false,
  }),
  vim.keymap.set("n", "<leader> ce", function()
    vim.cmd("Copilot enable")
    vim.notify("Copilot enabled", "info", { title = "Copilot" })
  end, { desc = "Enable Copilot" }),
  vim.keymap.set("n", "<leader> cd", function()
    vim.cmd("Copilot disable")
    vim.notify("Copilot disabled", "info", { title = "Copilot" })
  end, { desc = "Disable Copilot" }),
}
