local M = {}

M.ns = vim.api.nvim_create_namespace("markdown_slash_commands")
M.hl_group = "MarkdownSlashCommand"
M.max_lines = 5000

-- Garante definicao padrao caso o modulo carregue antes do tema
vim.api.nvim_set_hl(0, M.hl_group, {
  fg = "#cba6f7",
  bg = "#2e2640",
  bold = true,
  default = true,
})

local VALID_PREV = {
  [" "] = true,
  ["\t"] = true,
  ["("] = true,
  ["["] = true,
  ["{"] = true,
  ['"'] = true,
  ["'"] = true,
}

---Retorna todas as ocorrencias validas de /comando em uma lista de linhas
---@param lines string[]
---@return table[] lista de { lnum = 0-based, start_col = 0-based, end_col = 0-based exclusive }
function M.find_matches(lines)
  local matches = {}
  local in_code_block = false
  local fence_char = nil

  for idx, line in ipairs(lines) do
    local fence = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")
    if fence then
      local ch = fence:sub(1, 1)
      if not in_code_block then
        in_code_block = true
        fence_char = ch
      elseif fence_char == ch and line:match("^%s*" .. ch .. ch .. ch .. "+%s*$") then
        in_code_block = false
        fence_char = nil
      end
    elseif not in_code_block then
      local init = 1
      while true do
        local s, e = line:find("/[a-zA-Z][a-zA-Z0-9_%-:]*", init)
        if not s then
          break
        end

        local prev_ch = s > 1 and line:sub(s - 1, s - 1) or nil
        local next_ch = e < #line and line:sub(e + 1, e + 1) or nil

        local valid_before = (prev_ch == nil) or VALID_PREV[prev_ch]
        local valid_after = (next_ch ~= "/")

        if valid_before and valid_after then
          table.insert(matches, {
            lnum = idx - 1,
            start_col = s - 1,
            end_col = e,
          })
        end

        init = e + 1
      end
    end
  end

  return matches
end

---Aplica extmarks de destaque no buffer especificado
---@param bufnr? integer
function M.highlight(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if vim.bo[bufnr].filetype ~= "markdown" then
    vim.api.nvim_buf_clear_namespace(bufnr, M.ns, 0, -1)
    return
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, M.ns, 0, -1)
  if line_count == 0 or line_count > M.max_lines then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, line_count, false)
  local matches = M.find_matches(lines)

  for _, m in ipairs(matches) do
    vim.api.nvim_buf_set_extmark(bufnr, M.ns, m.lnum, m.start_col, {
      end_row = m.lnum,
      end_col = m.end_col,
      hl_group = M.hl_group,
      priority = 200,
    })
  end
end

return M
