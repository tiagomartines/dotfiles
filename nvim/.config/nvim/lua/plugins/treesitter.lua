return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local languages = {
        "bash",
        "dockerfile",
        "fish",
        "git_config",
        "gitcommit",
        "gitignore",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "query",
        "ruby",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }

      local supported_languages = {}
      for _, lang in ipairs(languages) do
        supported_languages[lang] = true
      end

      local treesitter = require("nvim-treesitter")
      local treesitter_log = require("nvim-treesitter.log")
      local install_root = vim.fn.stdpath("data") .. "/site/"
      local runtimepath = vim.opt.rtp:get()
      local found_install_root = false

      for i, path in ipairs(runtimepath) do
        if path == install_root or path == vim.fs.normalize(install_root) then
          runtimepath[i] = install_root
          found_install_root = true
        end
      end

      if not found_install_root then
        table.insert(runtimepath, 1, install_root)
      end

      vim.opt.rtp = runtimepath

      treesitter.setup({})

      local failed_languages = {}
      local installing_languages = {}
      local pending_buffers = {}
      local missing_cli_notified = false

      local silenced_languages = {}
      local captured_feedback = {}
      local silenced_install_count = 0
      local original_logger = {
        info = treesitter_log.Logger.info,
        warn = treesitter_log.Logger.warn,
        error = treesitter_log.Logger.error,
      }

      local function capture_log(ctx, level, message, ...)
        local lang = ctx and ctx:match("^install/(.+)$")
        if not lang or not silenced_languages[lang] then
          return false
        end

        if level ~= "info" then
          local bucket = captured_feedback[lang]
          if not bucket then
            bucket = {}
            captured_feedback[lang] = bucket
          end
          bucket[#bucket + 1] = message:format(...)
        end

        return true
      end

      local function patch_logger()
        if silenced_install_count == 0 then
          treesitter_log.Logger.info = function(self, message, ...)
            if capture_log(self.ctx, "info", message, ...) then
              return
            end
            return original_logger.info(self, message, ...)
          end

          treesitter_log.Logger.warn = function(self, message, ...)
            if capture_log(self.ctx, "warn", message, ...) then
              return
            end
            return original_logger.warn(self, message, ...)
          end

          treesitter_log.Logger.error = function(self, message, ...)
            if capture_log(self.ctx, "error", message, ...) then
              return message:format(...)
            end
            return original_logger.error(self, message, ...)
          end
        end

        silenced_install_count = silenced_install_count + 1
      end

      local function restore_logger()
        if silenced_install_count == 0 then
          return
        end

        silenced_install_count = silenced_install_count - 1
        if silenced_install_count > 0 then
          return
        end

        treesitter_log.Logger.info = original_logger.info
        treesitter_log.Logger.warn = original_logger.warn
        treesitter_log.Logger.error = original_logger.error
      end

      local function remember_buffer(lang, bufnr)
        local buffers = pending_buffers[lang]
        if not buffers then
          buffers = {}
          pending_buffers[lang] = buffers
        end
        buffers[bufnr] = true
      end

      local function enable_treesitter(bufnr, lang)
        if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
          return false
        end

        local has_parser = vim.treesitter.language.add(lang)
        if not has_parser then
          return false
        end

        local started = pcall(vim.treesitter.start, bufnr, lang)
        if not started then
          return false
        end

        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        return true
      end

      local function notify_failure(lang, message)
        vim.schedule(function()
          vim.notify(
            ("Failed to install Treesitter parser for %s: %s"):format(lang, message),
            vim.log.levels.WARN
          )
        end)
      end

      local function notify_missing_cli()
        if missing_cli_notified then
          return
        end

        missing_cli_notified = true
        vim.schedule(function()
          vim.notify(
            "Treesitter auto-install requires `tree-sitter` on the host. Install `tree-sitter-cli` and reopen Neovim.",
            vim.log.levels.WARN
          )
        end)
      end

      local function finish_install(lang, err, ok)
        silenced_languages[lang] = nil
        restore_logger()
        installing_languages[lang] = nil

        local feedback = captured_feedback[lang]
        captured_feedback[lang] = nil

        if err or not ok then
          failed_languages[lang] = true
          pending_buffers[lang] = nil

          local message = err
          if not message and feedback and #feedback > 0 then
            message = feedback[#feedback]
          end

          notify_failure(lang, message or "unknown error")
          return
        end

        failed_languages[lang] = nil

        local buffers = pending_buffers[lang] or {}
        pending_buffers[lang] = nil

        for bufnr in pairs(buffers) do
          enable_treesitter(bufnr, lang)
        end
      end

      local function install_language(lang, bufnr)
        if failed_languages[lang] then
          return
        end

        if installing_languages[lang] then
          remember_buffer(lang, bufnr)
          return
        end

        if vim.fn.executable("tree-sitter") ~= 1 then
          failed_languages[lang] = true
          notify_missing_cli()
          return
        end

        remember_buffer(lang, bufnr)
        installing_languages[lang] = true
        silenced_languages[lang] = true
        captured_feedback[lang] = {}
        patch_logger()

        local ok, task = pcall(treesitter.install, { lang })
        if not ok then
          finish_install(lang, task, false)
          return
        end

        task:await(function(err, installed)
          finish_install(lang, err, installed)
        end)
      end

      local group = vim.api.nvim_create_augroup("dotfiles_treesitter", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        desc = "Enable Treesitter highlighting and install missing parsers quietly",
        callback = function(args)
          local bufnr = args.buf
          local filetype = vim.bo[bufnr].filetype
          if filetype == "" then
            return
          end

          local lang = vim.treesitter.language.get_lang(filetype)
          if not lang then
            return
          end

          if enable_treesitter(bufnr, lang) then
            failed_languages[lang] = nil
            return
          end

          if #vim.api.nvim_list_uis() == 0 then
            return
          end

          if not supported_languages[lang] then
            return
          end

          install_language(lang, bufnr)
        end,
      })
    end,
  },
}
