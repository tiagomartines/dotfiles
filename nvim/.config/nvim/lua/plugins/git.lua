return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      on_attach = function(buffer)
        local gitsigns = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        map("n", "]h", gitsigns.next_hunk, "Next hunk")
        map("n", "[h", gitsigns.prev_hunk, "Prev hunk")
        map("n", "<leader>gp", gitsigns.preview_hunk, "Git preview hunk")
        map("n", "<leader>gb", gitsigns.toggle_current_line_blame, "Git toggle blame")
        map("n", "<leader>gh", gitsigns.reset_hunk, "Git reset hunk")
      end,
    },
  },
}
