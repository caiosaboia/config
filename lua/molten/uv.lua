local uv = vim.uv or vim.loop

local M = {}

---Localiza a raiz do projeto procurando arquivos de marcacao do UV
---@param start_path? string
---@return string?
function M.find_project_root(start_path)
  local current = start_path or vim.api.nvim_buf_get_name(0)
  if current == "" or current == nil then
    current = vim.fn.getcwd()
  else
    current = vim.fs.dirname(current)
  end

  local root_markers = { "uv.lock", "pyproject.toml", ".venv" }
  local found = vim.fs.find(root_markers, {
    path = current,
    upward = true,
    stop = vim.fn.expand("~"),
  })

  if found and #found > 0 then
    return vim.fs.dirname(found[1])
  end

  -- Fallback para o diretorio de trabalho atual
  local cwd = vim.fn.getcwd()
  for _, marker in ipairs(root_markers) do
    local p = cwd .. "/" .. marker
    if uv.fs_stat(p) then
      return cwd
    end
  end

  return nil
end

---Obtem o nome do projeto atraves do pyproject.toml ou nome do diretorio
---@param root_dir string
---@return string
function M.get_project_name(root_dir)
  local pyproject = root_dir .. "/pyproject.toml"
  local fd = uv.fs_open(pyproject, "r", 438)
  if fd then
    local stat = uv.fs_fstat(fd)
    if stat and stat.size > 0 then
      local content = uv.fs_read(fd, math.min(stat.size, 4096), 0)
      uv.fs_close(fd)
      if content then
        local name = content:match('name%s*=%s*"([^"]+)"') or content:match("name%s*=%s*'([^']+)'")
        if name then
          return name
        end
      end
    else
      uv.fs_close(fd)
    end
  end

  -- Fallback para o nome do diretorio
  local dir_name = vim.fs.basename(root_dir)
  return dir_name:gsub("[^%w_%-]", "-")
end

---Retorna o caminho do executavel python do .venv
---@param root_dir string
---@return string?
function M.get_venv_python(root_dir)
  local candidates = {
    root_dir .. "/.venv/Scripts/python.exe", -- Windows
    root_dir .. "/.venv/bin/python", -- Linux/macOS
  }
  for _, path in ipairs(candidates) do
    if uv.fs_stat(path) then
      return vim.fs.normalize(path)
    end
  end
  return nil
end

---Verifica se os pre-requisitos minimos (ipykernel) estao instalados no .venv
---@param python_path string
---@return boolean, string[]
function M.check_prerequisites(python_path)
  local missing = {}

  -- Checa ipykernel
  local cmd = { python_path, "-c", "import ipykernel" }
  local res = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    table.insert(missing, "ipykernel")
  end

  return #missing == 0, missing
end

---Emite notificacao visual clara sobre dependencias faltantes
---@param missing string[]
---@param root_dir string
function M.notify_missing(missing, root_dir)
  local missing_str = table.concat(missing, ", ")
  local msg = string.format(
    "Pre-requisito ausente no .venv:\n\n"
      .. "  -> %s\n\n"
      .. "O pacote '%s' e obrigatorio para o Molten executar codigo neste ambiente.\n\n"
      .. "Para instalar, execute no terminal do projeto (%s):\n"
      .. "  uv add --dev %s\n"
      .. "ou:\n"
      .. "  uv pip install %s",
    missing_str,
    missing_str,
    root_dir,
    missing_str,
    missing_str
  )

  local has_snacks, snacks = pcall(require, "snacks")
  if has_snacks and snacks.notify then
    snacks.notify.warn(msg, { title = "Molten UV", timeout = 10000 })
  else
    vim.notify(msg, vim.log.levels.WARN, { title = "Molten UV" })
  end
end

---Verifica e registra o kernel Jupyter para o projeto UV se necessario
---@param root_dir string
---@param project_name string
---@return boolean, string?
function M.ensure_kernel_spec(root_dir, project_name)
  local python_path = M.get_venv_python(root_dir)
  if not python_path then
    return false, "Executavel Python nao encontrado em .venv"
  end

  -- Verifica kernels existentes
  local list_res = vim.fn.system { "jupyter", "kernelspec", "list", "--json" }
  local existing_kernels = {}
  if vim.v.shell_error == 0 and list_res ~= "" then
    local ok, json = pcall(vim.fn.json_decode, list_res)
    if ok and json and json.kernelspecs then
      for k_name, _ in pairs(json.kernelspecs) do
        existing_kernels[k_name] = true
      end
    end
  end

  local kernel_name = "uv-" .. project_name
  if existing_kernels[kernel_name] or existing_kernels[project_name] then
    return true, existing_kernels[kernel_name] and kernel_name or project_name
  end

  -- Registra novo kernel spec apontando para o ambiente UV
  local display_name = string.format("%s (uv)", project_name)
  local install_cmd = {
    python_path,
    "-m",
    "ipykernel",
    "install",
    "--user",
    "--name=" .. kernel_name,
    "--display-name=" .. display_name,
  }

  local install_res = vim.fn.system(install_cmd)
  if vim.v.shell_error ~= 0 then
    return false, "Falha ao registrar kernel Jupyter: " .. tostring(install_res)
  end

  return true, kernel_name
end

---Ponto de entrada: detecta ambiente UV, valida pre-requisitos e conecta o Molten
function M.init_uv_kernel()
  local root = M.find_project_root()
  if not root then
    local msg = "Nenhum projeto UV encontrado no diretorio atual.\n"
      .. "Certifique-se de que existe um 'pyproject.toml', 'uv.lock' ou '.venv'."
    vim.notify(msg, vim.log.levels.ERROR, { title = "Molten UV" })
    return
  end

  local python_path = M.get_venv_python(root)
  if not python_path then
    local msg = string.format(
      "Ambiente '.venv' nao encontrado no projeto: %s\n\n"
        .. "Crie o ambiente virtual com o comando:\n"
        .. "  uv venv\n"
        .. "ou:\n"
        .. "  uv sync",
      root
    )
    vim.notify(msg, vim.log.levels.WARN, { title = "Molten UV" })
    return
  end

  -- Valida dependencias minimas (ipykernel)
  local ok_deps, missing = M.check_prerequisites(python_path)
  if not ok_deps then
    M.notify_missing(missing, root)
    return
  end

  -- Assegura presenca do kernel spec
  local project_name = M.get_project_name(root)
  local ok_kernel, kernel_or_err = M.ensure_kernel_spec(root, project_name)
  if not ok_kernel then
    vim.notify("Erro ao preparar kernel UV: " .. tostring(kernel_or_err), vim.log.levels.ERROR, { title = "Molten UV" })
    return
  end

  -- Conecta ao kernel do Molten
  vim.cmd("MoltenInit " .. kernel_or_err)

  local notify_msg = string.format("Molten conectado ao kernel UV: %s", kernel_or_err)
  local has_snacks, snacks = pcall(require, "snacks")
  if has_snacks and snacks.notify then
    snacks.notify.info(notify_msg, { title = "Molten UV" })
  else
    vim.notify(notify_msg, vim.log.levels.INFO, { title = "Molten UV" })
  end
end

return M
