return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      icons = {
        mappings = false,
      },
      spec = {
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
      },
    },
  },
}
