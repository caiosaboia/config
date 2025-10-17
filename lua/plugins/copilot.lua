return {
  "github/copilot.vim",
  vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false,
  }),
}
