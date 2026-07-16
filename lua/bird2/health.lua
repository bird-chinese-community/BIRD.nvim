--- Health check module for bird2.nvim
local M = {}

--- Run health checks
function M.check()
  vim.health.start("bird2.nvim")

  -- Check if plugin is loaded
  local bird2 = package.loaded["bird2"]
  if bird2 then
    vim.health.ok("Plugin loaded")
  else
    vim.health.warn("Plugin not loaded yet")
  end

  -- Check syntax file through the active runtime path.
  local syntax_path = vim.api.nvim_get_runtime_file("syntax/bird2.vim", false)[1]

  if syntax_path and vim.fn.filereadable(syntax_path) == 1 then
    vim.health.ok("Syntax file found: " .. syntax_path)
  else
    vim.health.error("Syntax file not found: " .. syntax_path)
  end

  -- Check Lua version
  local lua_version = _VERSION
  if lua_version then
    vim.health.info("Lua version: " .. lua_version)
  end

  -- Check Neovim version
  local nvim_version = vim.version()
  local version_str = string.format("v%d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch)
  if nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 9) then
    vim.health.ok("Neovim version: " .. version_str)
  else
    vim.health.warn("Neovim 0.9.0+ recommended (current: " .. version_str .. ")")
  end

  -- Check the registered detector rather than the user's config directory.
  if vim.filetype.match({ filename = "bird.conf" }) == "bird2" then
    vim.health.ok("Filetype detection installed")
  else
    vim.health.warn("Filetype detection may not be installed")
  end

  vim.health.info("For help, see: https://github.com/bird-chinese-community/bird2.nvim")
end

return M
