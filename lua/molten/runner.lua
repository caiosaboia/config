local M = {}

---Detecta delimitadores de celula no buffer atual
---@param bufnr? integer
---@return table[] lista de celulas { start_line = number, end_line = number, type = string, fence_start? = number, fence_end? = number, empty? = boolean }
function M.get_all_cells(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  local cells = {}

  if total_lines == 0 then
    return cells
  end

  if ft == "markdown" or ft == "quarto" then
    -- Parser de blocos markdown / quarto (```python ... ``` ou ```{python} ... ```)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, total_lines, false)
    local in_block = false
    local block_open_idx = nil
    local block_start = nil

    for idx, line in ipairs(lines) do
      if not in_block and line:match("^%s*```+") then
        in_block = true
        block_open_idx = idx
        block_start = idx + 1
      elseif in_block and line:match("^%s*```+%s*$") then
        in_block = false
        if block_start and block_start <= idx - 1 then
          table.insert(cells, {
            start_line = block_start,
            end_line = idx - 1,
            fence_start = block_open_idx,
            fence_end = idx,
            type = "markdown",
          })
        else
          table.insert(cells, {
            start_line = block_start,
            end_line = block_start - 1,
            fence_start = block_open_idx,
            fence_end = idx,
            type = "markdown",
            empty = true,
          })
        end
        block_open_idx = nil
        block_start = nil
      end
    end

    if in_block and block_start and block_start <= total_lines then
      table.insert(cells, {
        start_line = block_start,
        end_line = total_lines,
        fence_start = block_open_idx,
        fence_end = total_lines,
        type = "markdown",
      })
    end
  else
    -- Parser de scripts Python / Hydrogen (# %%, # In[], # <codecell>)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, total_lines, false)
    local cell_starts = {}

    for idx, line in ipairs(lines) do
      if line:match("^%s*#%s*%%%%") or line:match("^%s*#%s*In%[") or line:match("^%s*#%s*<codecell>") then
        table.insert(cell_starts, idx)
      end
    end

    if #cell_starts == 0 then
      -- Se nao tem delimitador, o buffer todo e tratado como uma celula unica
      table.insert(cells, { start_line = 1, end_line = total_lines, type = "whole_buffer" })
    else
      -- Se a primeira celula comeca apos a linha 1 e ha codigo antes
      if cell_starts[1] > 1 then
        table.insert(cells, { start_line = 1, end_line = cell_starts[1] - 1, type = "prelude" })
      end

      for i = 1, #cell_starts do
        local start_l = cell_starts[i]
        local end_l = (i < #cell_starts) and (cell_starts[i + 1] - 1) or total_lines
        table.insert(cells, { start_line = start_l, end_line = end_l, type = "percent" })
      end
    end
  end

  return cells
end

---Localiza a celula correspondente a linha fornecida
---@param line integer
---@param cells table[]
---@return table?, integer? celula e seu indice
function M.find_cell_at_line(line, cells)
  for idx, cell in ipairs(cells) do
    local s = cell.fence_start or cell.start_line
    local e = cell.fence_end or cell.end_line
    if line >= s and line <= e then
      return cell, idx
    end
  end
  return nil, nil
end

---Garante que o Molten esta inicializado antes de avaliar
---@return boolean
function M.ensure_molten()
  local ok, status = pcall(require, "molten.status")
  if ok and status.initialized and status.initialized() ~= "" then
    return true
  end

  local ok_uv, uv = pcall(require, "molten.uv")
  if not ok_uv then
    vim.notify("Modulo molten.uv nao encontrado.", vim.log.levels.ERROR, { title = "Molten Runner" })
    return false
  end

  local choice = vim.fn.confirm("Molten nao esta inicializado. Deseja inicializar com UV agora?", "&Sim\n&Nao", 1)
  if choice == 1 then
    uv.init_uv_kernel()
    return true
  end
  return false
end

---Avalia uma celula individual
---@param cell table
function M.evaluate_cell(cell)
  if not cell or cell.empty or (cell.start_line > cell.end_line) then
    return
  end
  if not M.ensure_molten() then
    return
  end
  local ok, err = pcall(vim.fn.MoltenEvaluateRange, cell.start_line, cell.end_line)
  if not ok then
    vim.notify("Erro ao executar celula com Molten: " .. tostring(err), vim.log.levels.ERROR, { title = "Molten Runner" })
  end
end

---Executa a celula atual sob o cursor
function M.run_cell()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local cells = M.get_all_cells()
  local cell, _ = M.find_cell_at_line(cursor_line, cells)
  if cell then
    M.evaluate_cell(cell)
  else
    vim.notify("Nenhuma celula encontrada sob o cursor.", vim.log.levels.WARN, { title = "Molten Runner" })
  end
end

---Executa a celula atual e avanca para a proxima
function M.run_cell_and_advance()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local cells = M.get_all_cells()
  local cell, idx = M.find_cell_at_line(cursor_line, cells)

  if not cell then
    for i, c in ipairs(cells) do
      local s = c.fence_start or c.start_line
      if s >= cursor_line then
        cell = c
        idx = i
        break
      end
    end
  end

  if cell then
    M.evaluate_cell(cell)
    if idx and idx < #cells then
      local next_cell = cells[idx + 1]
      vim.api.nvim_win_set_cursor(0, { next_cell.start_line, 0 })
    end
  else
    vim.notify("Nenhuma celula para executar e avancar.", vim.log.levels.WARN, { title = "Molten Runner" })
  end
end

---Avanca para a proxima celula e a executa
function M.run_next_cell()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local cells = M.get_all_cells()
  local _, idx = M.find_cell_at_line(cursor_line, cells)

  local target_cell = nil
  if idx and idx < #cells then
    target_cell = cells[idx + 1]
  elseif not idx then
    for _, c in ipairs(cells) do
      local s = c.fence_start or c.start_line
      if s > cursor_line then
        target_cell = c
        break
      end
    end
  end

  if target_cell then
    vim.api.nvim_win_set_cursor(0, { target_cell.start_line, 0 })
    M.evaluate_cell(target_cell)
  else
    vim.notify("Ja esta na ultima celula.", vim.log.levels.INFO, { title = "Molten Runner" })
  end
end

---Executa todas as celulas do buffer
function M.run_all()
  if not M.ensure_molten() then
    return
  end
  local cells = M.get_all_cells()
  if #cells == 0 then
    vim.notify("Nenhuma celula encontrada para executar.", vim.log.levels.WARN, { title = "Molten Runner" })
    return
  end

  local count = 0
  for _, cell in ipairs(cells) do
    if not cell.empty and cell.start_line <= cell.end_line then
      local ok, _ = pcall(vim.fn.MoltenEvaluateRange, cell.start_line, cell.end_line)
      if ok then
        count = count + 1
      end
    end
  end
  vim.notify(string.format("Executando %d celulas...", count), vim.log.levels.INFO, { title = "Molten Runner" })
end

---Executa todas as celulas acima (ate a atual)
function M.run_above()
  if not M.ensure_molten() then
    return
  end
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local cells = M.get_all_cells()
  local _, target_idx = M.find_cell_at_line(cursor_line, cells)

  if not target_idx then
    for i = #cells, 1, -1 do
      local e = cells[i].fence_end or cells[i].end_line
      if e <= cursor_line then
        target_idx = i
        break
      end
    end
  end

  if not target_idx then
    vim.notify("Nenhuma celula acima encontrada.", vim.log.levels.WARN, { title = "Molten Runner" })
    return
  end

  local count = 0
  for i = 1, target_idx do
    local cell = cells[i]
    if not cell.empty and cell.start_line <= cell.end_line then
      local ok, _ = pcall(vim.fn.MoltenEvaluateRange, cell.start_line, cell.end_line)
      if ok then
        count = count + 1
      end
    end
  end
  vim.notify(string.format("Executando %d celulas acima...", count), vim.log.levels.INFO, { title = "Molten Runner" })
end

---Executa da celula atual ate o final
function M.run_below()
  if not M.ensure_molten() then
    return
  end
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local cells = M.get_all_cells()
  local _, target_idx = M.find_cell_at_line(cursor_line, cells)

  if not target_idx then
    for i, cell in ipairs(cells) do
      local s = cell.fence_start or cell.start_line
      if s >= cursor_line then
        target_idx = i
        break
      end
    end
  end

  if not target_idx then
    vim.notify("Nenhuma celula abaixo encontrada.", vim.log.levels.WARN, { title = "Molten Runner" })
    return
  end

  local count = 0
  for i = target_idx, #cells do
    local cell = cells[i]
    if not cell.empty and cell.start_line <= cell.end_line then
      local ok, _ = pcall(vim.fn.MoltenEvaluateRange, cell.start_line, cell.end_line)
      if ok then
        count = count + 1
      end
    end
  end
  vim.notify(string.format("Executando %d celulas abaixo...", count), vim.log.levels.INFO, { title = "Molten Runner" })
end

---Navegacao: pular para a proxima celula
function M.jump_next()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local cells = M.get_all_cells()
  if #cells == 0 then
    return
  end

  local _, idx = M.find_cell_at_line(cursor_line, cells)
  if idx and idx < #cells then
    vim.api.nvim_win_set_cursor(0, { cells[idx + 1].start_line, 0 })
  elseif not idx then
    for _, cell in ipairs(cells) do
      local s = cell.fence_start or cell.start_line
      if s > cursor_line then
        vim.api.nvim_win_set_cursor(0, { cell.start_line, 0 })
        break
      end
    end
  end
end

---Navegacao: pular para a celula anterior
function M.jump_prev()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local cells = M.get_all_cells()
  if #cells == 0 then
    return
  end

  local _, idx = M.find_cell_at_line(cursor_line, cells)
  if idx and idx > 1 then
    vim.api.nvim_win_set_cursor(0, { cells[idx - 1].start_line, 0 })
  elseif not idx then
    for i = #cells, 1, -1 do
      local e = cells[i].fence_end or cells[i].end_line
      if e < cursor_line then
        vim.api.nvim_win_set_cursor(0, { cells[i].start_line, 0 })
        break
      end
    end
  end
end

return M
