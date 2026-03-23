vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.theme").setup()
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
