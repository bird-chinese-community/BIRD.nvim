local bird2 = require("bird2")

local function equal(expected, actual, label)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", label, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function truthy(value, label)
  equal(true, not not value, label)
end

local function falsy(value, label)
  equal(false, not not value, label)
end

local function new_buffer(lines, filename)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buffer)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  if filename then
    vim.api.nvim_buf_set_name(buffer, filename)
  end
  return buffer
end

local function delete_buffer(buffer)
  if vim.api.nvim_buf_is_valid(buffer) then
    vim.api.nvim_buf_delete(buffer, { force = true })
  end
end

equal("1.0.14", bird2.version, "plugin version")

local function check_heuristic(lines, expected, label)
  local buffer = new_buffer(lines)
  equal(expected, bird2.looks_like_bird2(buffer), label)
  delete_buffer(buffer)
end

check_heuristic({ "protocol evpn fabric {" }, true, "EVPN protocol")
check_heuristic({ "protocol aggregator routes {" }, true, "aggregator protocol")
check_heuristic({ "ipv6 sadr table source_specific;" }, true, "source-specific table")
check_heuristic({ "eth table layer2_routes;" }, true, "Ethernet table")
check_heuristic({ "neighbor table peers;" }, true, "neighbor table")
check_heuristic({ "ipv4-mpls table labels;" }, false, "address-family label is not a table type")
check_heuristic({ "table users {" }, false, "one generic table")
check_heuristic({ "filter inbound {", "  export all;" }, true, "two policy signals")
check_heuristic({ "/* protocol bgp hidden { */", "ordinary text" }, false, "block comments")

local bounded_lines = {}
for index = 1, 200 do
  bounded_lines[index] = "# ordinary configuration"
end
bounded_lines[201] = "protocol bgp too_late {"
check_heuristic(bounded_lines, false, "200 line bound")

equal("bird2", vim.filetype.match({ filename = "/tmp/bird2.conf" }), "exact filename")
equal("bird2", vim.filetype.match({ filename = "/etc/bird/custom.conf" }), "known directory")
falsy(vim.filetype.match({ filename = "/tmp/bluebird.conf" }) == "bird2", "unrelated filename")

local generic = new_buffer({ "filter inbound {", "  export all;" }, "/tmp/generic-policy.conf")
equal("bird2", vim.filetype.match({ buf = generic }), "content-based filetype match")
delete_buffer(generic)

bird2.config.heuristic_detect = false
local disabled = new_buffer({ "protocol bgp upstream {" }, "/tmp/disabled.conf")
falsy(vim.filetype.match({ buf = disabled }) == "bird2", "disabled heuristic")
delete_buffer(disabled)
bird2.config.heuristic_detect = true

local fallback = new_buffer({ "protocol bridge fabric {" }, "/tmp/fallback.conf")
vim.bo[fallback].filetype = "conf"
vim.api.nvim_exec_autocmds("BufWritePost", { buffer = fallback })
equal("bird2", vim.bo[fallback].filetype, "generic conf fallback")
delete_buffer(fallback)

local filetype_fallback = new_buffer({ "protocol evpn fabric {" }, "/tmp/filetype-fallback.conf")
vim.bo[filetype_fallback].filetype = "conf"
vim.api.nvim_exec_autocmds("FileType", { buffer = filetype_fallback })
equal("bird2", vim.bo[filetype_fallback].filetype, "FileType conf fallback")
delete_buffer(filetype_fallback)

local preserved = new_buffer({ "protocol bgp upstream {" }, "/tmp/preserved.conf")
vim.bo[preserved].filetype = "json"
vim.api.nvim_exec_autocmds("BufWritePost", { buffer = preserved })
equal("json", vim.bo[preserved].filetype, "preserve existing filetype")
delete_buffer(preserved)

local syntax_buffer = new_buffer({
  "mac set allowed = [ 02:00:00:00:00:01 ];",
  "int flags = (ifindex | 2) & 7;",
  "if ready && enabled || fallback then accept;",
  "local_metric = bgp_unknown_0x2a;",
  "proto_protocol_type = AF_IPV6;",
  "kbr_source = KBR_SRC_DYNAMIC;",
  "if bt_check_assign(net, 1) then accept;",
  "route net = 10.0.0.0/8{16,24};",
  "route net = ::/0;",
})
vim.cmd("runtime! syntax/bird2.vim")

local function syntax_group(line, needle)
  local column = vim.fn.stridx(vim.fn.getline(line), needle) + 1
  return vim.fn.synIDattr(vim.fn.synID(line, column, 1), "name")
end

equal("bird2Type", syntax_group(1, "mac set"), "mac set syntax")
equal("bird2Bitwise", syntax_group(2, "|"), "bitwise or syntax")
equal("bird2Bitwise", syntax_group(2, "&"), "bitwise and syntax")
equal("bird2Logical", syntax_group(3, "&&"), "logical and syntax")
equal("bird2Logical", syntax_group(3, "||"), "logical or syntax")
equal("bird2RouteAttr", syntax_group(4, "local_metric"), "local metric syntax")
equal("bird2RouteAttr", syntax_group(4, "bgp_unknown_0x2a"), "unknown BGP attr syntax")
equal("bird2RuntimeAttr", syntax_group(5, "proto_protocol_type"), "runtime attr syntax")
equal("bird2AddressFamilyConst", syntax_group(5, "AF_IPV6"), "address family syntax")
equal("bird2BridgeSourceConst", syntax_group(6, "KBR_SRC_DYNAMIC"), "bridge source syntax")
equal("bird2BuiltinFunc", syntax_group(7, "bt_check_assign"), "BIRD test builtin syntax")
equal("bird2Prefix", syntax_group(8, "{16,24}"), "IPv4 prefix range suffix syntax")
equal("bird2Prefix", syntax_group(9, "::/0"), "compressed IPv6 prefix syntax")

vim.bo[syntax_buffer].formatoptions = "tcqj"
bird2.on_attach(syntax_buffer)
local first_formatoptions = vim.bo[syntax_buffer].formatoptions
local first_matchpairs = vim.bo[syntax_buffer].matchpairs
falsy(first_formatoptions:find("t", 1, true), "disable automatic text wrapping")
bird2.on_attach(syntax_buffer)
equal(first_formatoptions, vim.bo[syntax_buffer].formatoptions, "idempotent format options")
equal(first_matchpairs, vim.bo[syntax_buffer].matchpairs, "idempotent matchpairs")
truthy(vim.fn.maparg("<Plug>Bird2Comment", "n", false, true).callback, "buffer mapping")
delete_buffer(syntax_buffer)

local mapped = new_buffer({ "protocol bgp upstream {" }, "/tmp/mapped.bird")
vim.keymap.set("n", "<leader>c", "<cmd>let g:bird2_preserved_mapping = 1<cr>", { buffer = mapped })
vim.bo[mapped].filetype = "bird2"
local leader_mapping = vim.fn.maparg("<leader>c", "n", false, true)
truthy(leader_mapping.rhs:find("bird2_preserved_mapping", 1, true), "preserve existing leader mapping")
vim.cmd("Bird2 disable")
equal(false, vim.b[mapped].bird2_enabled, "buffer command disables actions")
vim.cmd("Bird2 enable")
equal(true, vim.b[mapped].bird2_enabled, "buffer command enables actions")
delete_buffer(mapped)

local commented = new_buffer({ "  # indented", "    # nested" }, "/tmp/commented.bird")
vim.b[commented].bird2_enabled = true
vim.api.nvim_win_set_cursor(0, { 1, 0 })
bird2._toggle_comment()
equal("  indented", vim.api.nvim_get_current_line(), "normal uncomment preserves indentation")
bird2._toggle_comment()
equal("  # indented", vim.api.nvim_get_current_line(), "normal recomment preserves indentation")
vim.api.nvim_buf_set_mark(commented, "<", 1, 0, {})
vim.api.nvim_buf_set_mark(commented, ">", 2, 0, {})
bird2._toggle_comment_visual()
truthy(
  vim.deep_equal({ "  indented", "    nested" }, vim.api.nvim_buf_get_lines(commented, 0, -1, false)),
  "visual uncomment"
)
delete_buffer(commented)

local original_runtime_file = vim.api.nvim_get_runtime_file
local original_health = vim.health
local health_errors = {}
vim.api.nvim_get_runtime_file = function()
  return {}
end
vim.health = {
  start = function() end,
  ok = function() end,
  warn = function() end,
  info = function() end,
  error = function(message)
    table.insert(health_errors, message)
  end,
}
local health_ok, health_error = pcall(require("bird2.health").check)
vim.api.nvim_get_runtime_file = original_runtime_file
vim.health = original_health
truthy(health_ok, "health check tolerates missing syntax")
equal(nil, health_error, "missing syntax health error")
equal("Syntax file not found: syntax/bird2.vim", health_errors[1], "missing syntax message")

vim.cmd("qa!")
