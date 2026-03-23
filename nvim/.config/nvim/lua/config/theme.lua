local M = {}

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function detect_background()
  if vim.fn.has("macunix") == 1 then
    if vim.system then
      local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, {
        text = true,
      }):wait()

      if result.code == 0 and trim(result.stdout) == "Dark" then
        return "dark"
      end

      if result.code == 1 then
        return "light"
      end
    else
      local output = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })

      if vim.v.shell_error == 0 and trim(output) == "Dark" then
        return "dark"
      end

      if vim.v.shell_error == 1 then
        return "light"
      end
    end
  end

  if vim.o.background == "light" then
    return "light"
  end

  return "dark"
end

function M.apply(variant)
  local resolved = (variant == "light" or variant == "dark") and variant or detect_background()

  if vim.g.colors_name == "ghostty-xcode" and vim.g.ghostty_xcode_variant == resolved then
    return
  end

  vim.g.ghostty_xcode_variant = resolved
  vim.o.background = resolved

  local ok, err = pcall(vim.cmd.colorscheme, "ghostty-xcode")
  if not ok then
    vim.schedule(function()
      vim.notify("Failed to load ghostty-xcode colorscheme:\n" .. tostring(err), vim.log.levels.ERROR)
    end)
  end
end

function M.setup()
  M.apply()

  local group = vim.api.nvim_create_augroup("dotfiles_theme", { clear = true })

  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    desc = "Keep Neovim aligned with the current macOS appearance",
    callback = function()
      M.apply()
    end,
  })
end

return M
