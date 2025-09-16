return {
  "kiddos/gemini.nvim",
  opts = {
    model_config = {
      model_id = "gemini-2.5-pro",
      temperature = 0.10,
      top_k = 128,
      max_output_tokens = 8196,
      response_mime_type = "text/plain",
    },
    completion = {
      insert_result_key = "<C-L>",
    },
  },
}
