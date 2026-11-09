local uv = vim.uv or vim.loop

---@class AntigravityBlinkSource
---@field opts table
local Source = {}

-- Cache em memoria para skills escaneadas
local _skills_cache = nil

-- Slash commands nativos do Antigravity CLI
local CORE_COMMANDS = {
  {
    name = "goal",
    desc = "Executa tarefas longas e autonomas (modo overnight) sem parar ate o objetivo ser atingido.",
  },
  {
    name = "plan",
    desc = "Cria um plano de implementacao detalhado e solicita feedback antes de modificar o codigo.",
  },
  {
    name = "grill-me",
    desc = "Entrevista interativa passo a passo para alinhar decisoes tecnicas e requisitos de design.",
  },
  {
    name = "schedule",
    desc = "Agenda uma instrucao recorrente (cron) ou define um temporizador pontual.",
  },
  {
    name = "browser",
    desc = "Habilita navegacao na web, pesquisas ou interacao direta com aplicacoes web.",
  },
  {
    name = "compact",
    desc = "Compacta ou resume o contexto da conversa para liberar espaco na janela de contexto.",
  },
  {
    name = "teamwork",
    desc = "Orquestra uma equipe de agentes autonomos trabalhando em paralelo em projetos complexos.",
  },
  {
    name = "learn",
    desc = "Persiste regras, correcoes e comportamentos aprendidos para tarefas futuras.",
  },
  {
    name = "boost",
    desc = "Ativa raciocinio profundo, planejamento estrategico e verificacao rigorosa.",
  },
  {
    name = "clear",
    desc = "Limpa o historico da conversa atual e inicia uma nova sessao limpa.",
  },
  {
    name = "help",
    desc = "Exibe ajuda e documentacao dos comandos disponiveis no Antigravity CLI.",
  },
  {
    name = "exit",
    desc = "Encerra a sessao do Antigravity CLI.",
  },
  {
    name = "mode",
    desc = "Define o modo de execucao do agente (accept-edits, auto, plan).",
  },
  {
    name = "model",
    desc = "Altera o modelo de linguagem utilizado na sessao ativa.",
  },
  {
    name = "effort",
    desc = "Configura o nivel de esforco de raciocinio (low, medium, high, xhigh, max).",
  },
}

---Limpa o cache em memoria de skills
function Source.clear_cache()
  _skills_cache = nil
end

---Escaneia uma pasta de skills e le metadados de SKILL.md
---@param parent_dir string
---@return table
local function scan_skill_folder(parent_dir)
  local handle = uv.fs_scandir(parent_dir)
  if not handle then
    return {}
  end

  local results = {}
  while true do
    local name, entry_type = uv.fs_scandir_next(handle)
    if not name then
      break
    end
    if entry_type == "directory" then
      local skill_md = parent_dir .. "/" .. name .. "/SKILL.md"
      local fd = uv.fs_open(skill_md, "r", 438)
      if fd then
        local stat = uv.fs_fstat(fd)
        if stat and stat.size > 0 then
          local read_size = math.min(stat.size, 3072)
          local content = uv.fs_read(fd, read_size, 0)
          if content then
            local desc = content:match("description:%s*([^\r\n]+)")
            if desc then
              desc = desc:gsub("^[\"\'%s]+", ""):gsub("[\"\'%s]+$", "")
            end
            table.insert(results, {
              name = name,
              desc = desc or "Antigravity Skill",
              path = skill_md,
            })
          end
        end
        uv.fs_close(fd)
      end
    end
  end
  return results
end

---Retorna todas as skills descobertas dinamicamente (com cache)
---@return table
function Source.get_skills()
  if _skills_cache then
    return _skills_cache
  end

  local list = {}
  local base = vim.fn.expand("~/.gemini")

  -- 1. Skills principais de usuario
  vim.list_extend(list, scan_skill_folder(base .. "/antigravity-cli/skills"))

  -- 2. Skills builtin da CLI
  vim.list_extend(list, scan_skill_folder(base .. "/antigravity-cli/builtin/skills"))

  -- 3. Skills instaladas via plugins
  local plugins_dir = base .. "/config/plugins"
  local p_handle = uv.fs_scandir(plugins_dir)
  if p_handle then
    while true do
      local p_name, p_type = uv.fs_scandir_next(p_handle)
      if not p_name then
        break
      end
      if p_type == "directory" then
        local sub_skill_dir = plugins_dir .. "/" .. p_name .. "/skills"
        vim.list_extend(list, scan_skill_folder(sub_skill_dir))
      end
    end
  end

  _skills_cache = list
  return _skills_cache
end

---Construtor exigido pelo blink.cmp
---@param opts? table
---@return AntigravityBlinkSource
function Source.new(opts)
  local self = setmetatable({}, { __index = Source })
  self.opts = opts or {}
  return self
end

---Caracteres que disparam a verificacao de completamento
---@return string[]
function Source:get_trigger_characters()
  return { "/" }
end

---Verifica se o contexto atual permite auto-complete de comandos
---@return boolean
function Source:enabled()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  -- Formatos de texto e documentacao sempre habilitados
  local allowed_ft = {
    markdown = true,
    text = true,
    gitcommit = true,
    prompt = true,
    ["copilot-chat"] = true,
    ["AvanteInput"] = true,
    ["snacks_input"] = true,
  }
  if allowed_ft[ft] then
    return true
  end

  -- Em arquivos de codigo, aceita caso o cursor esteja em comentario
  local ok, node = pcall(vim.treesitter.get_node)
  if ok and node then
    local node_type = node:type()
    if node_type:find("comment") then
      return true
    end
  end

  -- Fallback de verificacao de linha de comentario ou espaco
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*[%-%#%/%*]") then
    return true
  end

  return false
end

---Fornece as sugestoes de completamento para o blink.cmp
---@param context table
---@param callback fun(response: table)
function Source:get_completions(context, callback)
  local line_before_cursor = context.line:sub(1, context.cursor[2])
  local slash_pos = line_before_cursor:match(".*()/")

  -- Se nao houver barra digitada na linha antes do cursor, aborta
  if not slash_pos then
    return callback({
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = {},
    })
  end

  -- Valida se a barra foi precedida por espaco, inicio de linha ou comentario
  if slash_pos > 1 then
    local char_before = line_before_cursor:sub(slash_pos - 1, slash_pos - 1)
    local is_safe_prefix = char_before:match("%s")
      or line_before_cursor:sub(1, slash_pos - 1):match("[%-%#%/%*\"'`]%s*$")
    if not is_safe_prefix then
      return callback({
        is_incomplete_forward = false,
        is_incomplete_backward = false,
        items = {},
      })
    end
  end

  -- Se houver espaco depois da barra, o usuario ja completou o comando
  local text_after_slash = line_before_cursor:sub(slash_pos + 1)
  if text_after_slash:match("%s") then
    return callback({
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = {},
    })
  end

  -- Range de substituicao: desde a barra ate a posicao atual do cursor
  local line_idx = context.cursor[1] - 1
  local slash_col = slash_pos - 1
  local cursor_col = context.cursor[2]

  local range = {
    start = { line = line_idx, character = slash_col },
    ["end"] = { line = line_idx, character = cursor_col },
  }

  local items = {}
  local CompletionItemKind = vim.lsp.protocol.CompletionItemKind

  -- 1. Slash commands nativos (prioridade maxima)
  for _, cmd in ipairs(CORE_COMMANDS) do
    local label = "/" .. cmd.name
    table.insert(items, {
      label = label,
      filterText = label,
      sortText = "0_" .. cmd.name,
      kind = CompletionItemKind.Keyword,
      detail = "Antigravity Slash Command",
      documentation = {
        kind = "markdown",
        value = string.format("### %s\n\n%s", label, cmd.desc),
      },
      insertText = label .. " ",
      textEdit = {
        newText = label .. " ",
        range = range,
      },
    })
  end

  -- 2. Skills descobertas dinamicamente
  local skills = Source.get_skills()
  for _, skill in ipairs(skills) do
    local label = "/" .. skill.name
    table.insert(items, {
      label = label,
      filterText = label,
      sortText = "1_" .. skill.name,
      kind = CompletionItemKind.Function,
      detail = "Antigravity Skill",
      documentation = {
        kind = "markdown",
        value = string.format("### %s\n\n%s", label, skill.desc),
      },
      insertText = label .. " ",
      textEdit = {
        newText = label .. " ",
        range = range,
      },
    })
  end

  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items,
  })
end

return Source
