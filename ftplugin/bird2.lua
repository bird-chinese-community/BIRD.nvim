-- BIRD2 filetype plugin
-- This file runs when a bird2 file is opened

local bird2 = require("bird2")

-- Setup the plugin for this buffer
bird2.on_attach(0)

-- Define buffer-local commands
vim.api.nvim_buf_create_user_command(0, "Bird2", function(opts)
  local subcommand = opts.fargs[1]

  if subcommand == "version" then
    print("bird2.nvim " .. bird2.version)
  elseif subcommand == "check" then
    vim.cmd("checkhealth bird2")
  elseif subcommand == "disable" then
    vim.b.bird2_enabled = false
  elseif subcommand == "enable" then
    vim.b.bird2_enabled = true
    bird2.on_attach(0)
  else
    print("Usage: Bird2 [version|check|enable|disable]")
  end
end, {
  nargs = "?",
  complete = function()
    return { "version", "check", "enable", "disable" }
  end,
  desc = "BIRD2 plugin commands",
})

local function mapping_is_available(mode)
  local mapping = vim.fn.maparg("<leader>c", mode, false, true)
  return type(mapping) ~= "table" or vim.tbl_isempty(mapping)
end

-- Define optional buffer-local defaults without replacing user mappings.
if bird2.config.enabled and vim.b.bird2_enabled ~= false then
  if mapping_is_available("n") then
    vim.keymap.set("n", "<leader>c", "<Plug>Bird2Comment", {
      buffer = 0,
      desc = "Toggle comment",
    })
  end

  if mapping_is_available("x") then
    vim.keymap.set("x", "<leader>c", "<Plug>Bird2Comment", {
      buffer = 0,
      desc = "Toggle comment (visual)",
    })
  end
end

-- LSP configuration suggestions (for future use)
-- Uncomment if you have a BIRD2 LSP server
-- if vim.bo.filetype == "bird2" then
--   vim.lsp.start({
--     name = "bird2",
--     cmd = { "bird2-language-server" },
--     root_dir = vim.fs.root(0, { "bird.conf", "bird6.conf" }),
--   })
-- end
