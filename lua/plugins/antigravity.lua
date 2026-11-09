---@type LazySpec
return {
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        default = { "antigravity" },
        providers = {
          antigravity = {
            name = "antigravity",
            module = "antigravity.blink_source",
            score_offset = 100,
            opts = {},
          },
        },
      },
    },
  },
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      opts.commands = opts.commands or {}
      opts.commands.AntigravityReload = {
        function()
          local ok, src = pcall(require, "antigravity.blink_source")
          if ok then
            src.clear_cache()
            local count = #src.get_skills()
            vim.notify(string.format("Antigravity: cache recarregado com %d skills", count), vim.log.levels.INFO)
          end
        end,
        desc = "Recarrega o cache de skills do Antigravity CLI",
      }
    end,
  },
}
