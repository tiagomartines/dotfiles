local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.showmode = false
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}
opt.inccommand = "split"
opt.cursorline = true
opt.scrolloff = 4
opt.confirm = true
opt.termguicolors = true
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.completeopt = { "menu", "menuone", "noselect" }

if vim.fn.has("nvim-0.11") == 1 then
  opt.winborder = "rounded"
end
