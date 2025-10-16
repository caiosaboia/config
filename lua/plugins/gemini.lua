return {
  "kiddos/gemini.nvim",
  opts = {
    model_config = {
      model_id = "gemini-2.5-pro",
      temperature = 0.3,
    },
    completion = {
      insert_result_key = "<C-l>",
    },
  },
}
