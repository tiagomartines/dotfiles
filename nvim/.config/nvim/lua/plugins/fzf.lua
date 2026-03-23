return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      {
        "<leader>ff",
        function()
          require("fzf-lua").files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("fzf-lua").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>ft",
        function()
          local fzf = require("fzf-lua")
          local actions = require("fzf-lua.actions")

          fzf.files({
            actions = {
              ["enter"] = actions.file_tabedit,
            },
          })
        end,
        desc = "Find files in tab",
      },
      {
        "<leader>fb",
        function()
          require("fzf-lua").buffers()
        end,
        desc = "Find buffers",
      },
      {
        "<leader>fh",
        function()
          require("fzf-lua").helptags()
        end,
        desc = "Help tags",
      },
    },
    opts = {},
  },
}
