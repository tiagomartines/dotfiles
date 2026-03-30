return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      on_attach = function(buffer)
        local gitsigns = package.loaded.gitsigns
        local open_lazygit = function()
          local root = vim.fs.root(buffer, { ".git" }) or vim.uv.cwd()

          vim.cmd("botright 15new")
          local term_buf = vim.api.nvim_get_current_buf()
          local term_win = vim.api.nvim_get_current_win()

          vim.fn.termopen("lazygit", {
            cwd = root,
            on_exit = function()
              vim.schedule(function()
                if vim.api.nvim_win_is_valid(term_win) then
                  vim.api.nvim_win_close(term_win, true)
                elseif vim.api.nvim_buf_is_valid(term_buf) then
                  vim.api.nvim_buf_delete(term_buf, { force = true })
                end
              end)
            end,
          })

          vim.cmd("startinsert")
        end

        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        map("n", "]h", gitsigns.next_hunk, "Next hunk")
        map("n", "[h", gitsigns.prev_hunk, "Prev hunk")
        map("n", "<leader>gg", open_lazygit, "Git lazygit")
        map("n", "<leader>gp", gitsigns.preview_hunk, "Git preview hunk")
        map("n", "<leader>gb", gitsigns.toggle_current_line_blame, "Git toggle blame")
        map("n", "<leader>gh", gitsigns.reset_hunk, "Git reset hunk")
      end,
    },
  },
}
