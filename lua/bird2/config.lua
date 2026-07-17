--- Configuration management for bird2.nvim
local M = {}

--- Get a configuration value
--- @param key string Configuration key
--- @return any value Configuration value
function M.get(key)
  local bird2 = require("bird2")
  return bird2.config[key]
end

--- Set a configuration value
--- @param key string Configuration key
--- @param value any Configuration value
function M.set(key, value)
  local bird2 = require("bird2")
  bird2.config[key] = value
end

--- Check if heuristic detection is enabled
--- @return boolean enabled
function M.heuristic_enabled()
  return M.get("enabled") ~= false and M.get("heuristic_detect") ~= false
end

return M
