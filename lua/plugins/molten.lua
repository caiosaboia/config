---@type LazySpec
return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "none"
      vim.g.molten_output_win_max_height = 20
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
