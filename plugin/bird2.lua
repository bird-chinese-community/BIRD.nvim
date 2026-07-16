-- BIRD 2/3 filetype registration and content-based detection

local api = vim.api
local bird2 = require("bird2")
local config = require("bird2.config")

local function heuristic_filetype(_, bufnr)
  if bufnr and config.heuristic_enabled() and bird2.looks_like_bird2(bufnr) then
    return "bird2"
  end
end

if vim.filetype and vim.filetype.add then
  vim.filetype.add({
    extension = {
      bird = "bird2",
      bird2 = "bird2",
      bird3 = "bird2",
    },
    filename = {
      ["bird.conf"] = "bird2",
      ["bird2.conf"] = "bird2",
      ["bird3.conf"] = "bird2",
      ["bird6.conf"] = "bird2",
    },
    pattern = {
      [".*/bird[23]?/.*%.conf"] = { "bird2", { priority = 20 } },
      [".*/bird[-_.].*%.conf"] = { "bird2", { priority = 10 } },
      [".*/.*%.bird[23]?%.conf"] = { "bird2", { priority = 10 } },
      [".*%.conf"] = { heuristic_filetype, { priority = -math.huge } },
    },
  })
end

local function maybe_set_filetype(bufnr)
  local current_ft = vim.bo[bufnr].filetype
  if current_ft == "bird2" then
    return
  end
  if current_ft ~= "" and current_ft ~= "conf" then
    return
  end
  if config.heuristic_enabled() and bird2.looks_like_bird2(bufnr) then
    vim.bo[bufnr].filetype = "bird2"
  end
end

local detection_group = api.nvim_create_augroup("Bird2FiletypeDetection", { clear = true })
api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufWritePost" }, {
  group = detection_group,
  pattern = "*.conf",
  callback = function(args)
    maybe_set_filetype(args.buf)
  end,
  desc = "BIRD 2/3: detect generic .conf files from their contents",
})

api.nvim_create_autocmd("FileType", {
  group = detection_group,
  pattern = "conf",
  callback = function(args)
    maybe_set_filetype(args.buf)
  end,
  desc = "BIRD 2/3: upgrade generic conf filetypes from their contents",
})

api.nvim_create_user_command("Bird2Health", function()
  vim.cmd("checkhealth bird2")
end, { desc = "Check bird2.nvim health" })
