return {
  "kiddos/gemini.nvim",
  opts = {
    model_config = {
      model_id = "gemini-2.5-pro",
      temperature = 0.7,
    },
    completion = {
      enabled = true,
      insert_result_key = "<C-l>",
      move_cursor_end = true,
    },
  },
}
