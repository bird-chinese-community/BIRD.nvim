vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.cmd("filetype plugin on")
vim.cmd("syntax enable")

require("bird2").setup()
