return {
  "github/copilot.vim",
  vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', {
    expr = true,
    replace_keycodes = false,
  }),
  vim.keymap.set("n", "<leader> ce", "<cmd>Copilot enable<CR>", { desc = "Enable Copilot" }),
  vim.keymap.set("n", "<leader> cd", "<cmd>Copilot disable<CR>", { desc = "Disable Copilot" }),
}
