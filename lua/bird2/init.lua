--- BIRD2 Neovim plugin
--- @class bird2.Config
--- @field enabled boolean Whether to enable the plugin
--- @field heuristic_detect boolean Enable heuristic detection for .conf files

local M = {}

M.version = "1.0.12"

--- Default configuration
--- @type bird2.Config
M.defaults = {
  enabled = true,
  heuristic_detect = true,
}

--- Module configuration
--- @type bird2.Config
M.config = vim.deepcopy(M.defaults)

--- Setup the plugin
--- @param opts? bird2.Config User configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  local augroup = vim.api.nvim_create_augroup("bird2", { clear = true })

  if not M.config.enabled then
    return
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "bird2",
    callback = function(args)
      M.on_attach(args.buf)
    end,
  })
end

--- Buffer-local setup when filetype is detected
--- @param bufnr number Buffer number
function M.on_attach(bufnr)
  bufnr = bufnr or 0

  if not vim.api.nvim_buf_is_valid(bufnr) or not M.config.enabled or vim.b[bufnr].bird2_enabled == false then
    return
  end

  vim.b[bufnr].bird2_enabled = true

  -- Set comment format
  vim.bo[bufnr].commentstring = "# %s"
  vim.bo[bufnr].comments = ":#"

  -- Set buffer-local options without duplicating flags on repeated attaches.
  local formatoptions = vim.bo[bufnr].formatoptions:gsub("t", "")
  for flag in ("croql"):gmatch(".") do
    if not formatoptions:find(flag, 1, true) then
      formatoptions = formatoptions .. flag
    end
  end
  vim.bo[bufnr].formatoptions = formatoptions

  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.matchpairs:append("(:)")
    vim.opt_local.matchpairs:append("{:}")
    vim.opt_local.matchpairs:append("[:]")
    vim.cmd("syntax sync fromstart")
  end)

  -- Create buffer-local key mappings
  M._create_mappings(bufnr)

  -- Run user autocommand
  vim.api.nvim_exec_autocmds("User", {
    pattern = "Bird2File",
    data = { buf = bufnr },
  })
end

--- Create buffer-local key mappings
--- @param bufnr number Buffer number
function M._create_mappings(bufnr)
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set("n", "<Plug>Bird2Comment", M._toggle_comment, opts)
  vim.keymap.set("x", "<Plug>Bird2Comment", M._toggle_comment_visual, opts)
end

--- Toggle comment for current line
--- @param _ any Unused
function M._toggle_comment(_)
  if vim.b.bird2_enabled == false then
    return
  end

  local line = vim.api.nvim_get_current_line()
  local trimmed = line:match("^%s*(.*)")

  if trimmed:match("^#") then
    -- Uncomment
    local uncommented = line:gsub("^(%s*)#%s?", "%1", 1)
    vim.api.nvim_set_current_line(uncommented)
  else
    -- Comment
    local commented = line:gsub("^(%s*)", "%1# ", 1)
    vim.api.nvim_set_current_line(commented)
  end
end

--- Toggle comment for visual selection
function M._toggle_comment_visual()
  if vim.b.bird2_enabled == false then
    return
  end

  local start = vim.api.nvim_buf_get_mark(0, "<")
  local end_ = vim.api.nvim_buf_get_mark(0, ">")
  local start_row = start[1]
  local end_row = end_[1]

  for row = start_row, end_row do
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local trimmed = line:match("^%s*(.*)")

    if trimmed:match("^#") then
      -- Uncomment
      local uncommented = line:gsub("^(%s*)#%s?", "%1", 1)
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { uncommented })
    else
      -- Comment
      local commented = line:gsub("^(%s*)", "%1# ", 1)
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { commented })
    end
  end
end

local protocols = {
  aggregator = true,
  babel = true,
  bfd = true,
  bgp = true,
  bmp = true,
  bridge = true,
  device = true,
  direct = true,
  evpn = true,
  kernel = true,
  l3vpn = true,
  mrt = true,
  ospf = true,
  perf = true,
  pipe = true,
  radv = true,
  rip = true,
  rpki = true,
  static = true,
}

local table_types = {
  aspa = true,
  eth = true,
  evpn = true,
  flow4 = true,
  flow6 = true,
  ipv4 = true,
  ipv6 = true,
  mpls = true,
  neighbor = true,
  roa4 = true,
  roa6 = true,
  vpn4 = true,
  vpn6 = true,
}

local policy_values = { all = true, filter = true, none = true, where = true }

local function strip_comments(line, in_block_comment)
  local output = line

  if in_block_comment then
    local block_end = output:find("*/", 1, true)
    if not block_end then
      return "", true
    end
    output = output:sub(block_end + 2)
    in_block_comment = false
  end

  while true do
    local block_start = output:find("/*", 1, true)
    if not block_start then
      break
    end

    local block_end = output:find("*/", block_start + 2, true)
    if block_end then
      output = output:sub(1, block_start - 1) .. output:sub(block_end + 2)
    else
      output = output:sub(1, block_start - 1)
      in_block_comment = true
      break
    end
  end

  return output:gsub("#.*$", ""), in_block_comment
end

local function is_strong_signal(line)
  if line:match("^%s*router%s+id%f[%W]") then
    return true
  end

  local declaration, protocol = line:match("^%s*(%a+)%s+([%w_]+)")
  if (declaration == "protocol" or declaration == "template") and protocols[protocol] then
    return true
  end

  if line:match("^%s*ipv6%s+sadr%s+table%f[%W]") then
    return true
  end

  local table_type = line:match("^%s*([%w_]+)%s+table%f[%W]")
  return table_type ~= nil and table_types[table_type] == true
end

local function collect_signals(line, signals)
  if line:match("^%s*filter%s+[%w_']+") then
    signals.filter = true
  end
  if line:match("^%s*function%s+[%w_']+") then
    signals["function"] = true
  end
  if line:match("^%s*define%s+[%w_']+%s*=") then
    signals.define = true
  end
  if line:match("^%s*table%s+[%w_']+%s*{") then
    signals.table = true
  end
  local direction, policy = line:match("^%s*(%a+)%s+(%a+)")
  if (direction == "import" or direction == "export") and policy_values[policy] then
    signals.policy = true
  end
  if line:match("^%s*accept%s*;") or line:match("^%s*reject%s*;") then
    signals.decision = true
  end
  if line:match("^%s*include%s+[\"']") then
    signals.include = true
  end
end

local function signal_count(signals)
  local count = 0
  for _ in pairs(signals) do
    count = count + 1
  end
  return count
end

--- Check if a buffer looks like a BIRD 2 or BIRD 3 config
--- @param bufnr number Buffer number
--- @return boolean is_bird2
function M.looks_like_bird2(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local total = vim.api.nvim_buf_line_count(bufnr)
  local max = math.min(total, 200)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, max, false)
  local signals = {}
  local in_block_comment = false

  for _, raw_line in ipairs(lines) do
    local line
    line, in_block_comment = strip_comments(raw_line:lower(), in_block_comment)

    if not line:match("^%s*$") then
      if is_strong_signal(line) then
        return true
      end

      collect_signals(line, signals)
      if signal_count(signals) >= 2 then
        return true
      end
    end
  end

  return false
end

return M
