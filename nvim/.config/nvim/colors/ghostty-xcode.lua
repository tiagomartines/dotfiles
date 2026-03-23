local palettes = {
  light = {
    bg = "#ffffff",
    fg = "#000000",
    muted = "#8a99a6",
    selection = "#b4d8fd",
    cursor = "#000000",
    red = "#ad1805",
    orange = "#78492a",
    yellow = "#78492a",
    teal = "#355d61",
    green = "#174145",
    blue = "#0058a1",
    blue_bright = "#003f73",
    magenta = "#9c2191",
    purple = "#703daa",
    violet = "#441ea1",
    terminal = {
      "#b4d8fd",
      "#ad1805",
      "#355d61",
      "#78492a",
      "#0058a1",
      "#9c2191",
      "#703daa",
      "#000000",
      "#8a99a6",
      "#ad1805",
      "#174145",
      "#78492a",
      "#003f73",
      "#9c2191",
      "#441ea1",
      "#000000",
    },
  },
  dark = {
    bg = "#1f1f24",
    fg = "#ffffff",
    muted = "#838991",
    selection = "#43454b",
    cursor = "#ffffff",
    red = "#ff8a7a",
    orange = "#ffa14f",
    yellow = "#d9c668",
    teal = "#83c9bc",
    green = "#b1faeb",
    blue = "#4ec4e6",
    blue_bright = "#6bdfff",
    magenta = "#ff85b8",
    purple = "#cda1ff",
    violet = "#e5cfff",
    terminal = {
      "#43454b",
      "#ff8a7a",
      "#83c9bc",
      "#d9c668",
      "#4ec4e6",
      "#ff85b8",
      "#cda1ff",
      "#ffffff",
      "#838991",
      "#ff8a7a",
      "#b1faeb",
      "#ffa14f",
      "#6bdfff",
      "#ff85b8",
      "#e5cfff",
      "#ffffff",
    },
  },
}

local variant = vim.g.ghostty_xcode_variant
if variant ~= "light" and variant ~= "dark" then
  variant = vim.o.background == "light" and "light" or "dark"
end

local p = palettes[variant]

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function blend(fg, bg, alpha)
  local fr, fgc, fb = hex_to_rgb(fg)
  local br, bgc, bb = hex_to_rgb(bg)

  local function channel(foreground, background)
    return math.floor((alpha * foreground) + ((1 - alpha) * background) + 0.5)
  end

  return string.format(
    "#%02x%02x%02x",
    channel(fr, br),
    channel(fgc, bgc),
    channel(fb, bb)
  )
end

local ui = {
  surface = blend(p.selection, p.bg, variant == "light" and 0.18 or 0.30),
  surface_strong = blend(p.selection, p.bg, variant == "light" and 0.30 or 0.42),
  border = blend(p.muted, p.bg, variant == "light" and 0.55 or 0.65),
  search = blend(p.blue, p.bg, variant == "light" and 0.18 or 0.24),
  diff_add = blend(p.green, p.bg, variant == "light" and 0.18 or 0.20),
  diff_change = blend(p.blue, p.bg, variant == "light" and 0.15 or 0.18),
  diff_delete = blend(p.red, p.bg, variant == "light" and 0.18 or 0.20),
  diff_text = blend(p.blue_bright, p.bg, variant == "light" and 0.22 or 0.28),
  diag_error = blend(p.red, p.bg, variant == "light" and 0.10 or 0.18),
  diag_warn = blend(p.orange, p.bg, variant == "light" and 0.12 or 0.18),
  diag_info = blend(p.blue, p.bg, variant == "light" and 0.12 or 0.18),
  diag_hint = blend(p.teal, p.bg, variant == "light" and 0.12 or 0.18),
}

local function set(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

local function link(group, target)
  set(group, { link = target })
end

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.g.colors_name = "ghostty-xcode"

for index, color in ipairs(p.terminal) do
  vim.g["terminal_color_" .. (index - 1)] = color
end

set("Normal", { fg = p.fg, bg = p.bg })
set("NormalNC", { fg = p.fg, bg = p.bg })
set("NormalFloat", { fg = p.fg, bg = ui.surface })
set("FloatBorder", { fg = ui.border, bg = ui.surface })
set("FloatTitle", { fg = p.blue_bright, bg = ui.surface, bold = true })
set("Cursor", { fg = p.bg, bg = p.cursor })
set("lCursor", { fg = p.bg, bg = p.cursor })
set("TermCursor", { fg = p.bg, bg = p.cursor })
set("CursorLine", { bg = ui.surface })
set("CursorColumn", { bg = ui.surface })
set("ColorColumn", { bg = ui.surface })
set("CursorLineNr", { fg = p.blue_bright, bold = true })
set("LineNr", { fg = p.muted })
set("SignColumn", { fg = p.muted, bg = p.bg })
set("WinSeparator", { fg = ui.border })
link("VertSplit", "WinSeparator")
set("StatusLine", { fg = p.fg, bg = ui.surface_strong })
set("StatusLineNC", { fg = p.muted, bg = ui.surface })
set("TabLine", { fg = p.muted, bg = ui.surface })
set("TabLineFill", { fg = p.muted, bg = p.bg })
set("TabLineSel", { fg = p.fg, bg = ui.surface_strong, bold = true })
set("Pmenu", { fg = p.fg, bg = ui.surface })
set("PmenuSel", { fg = p.fg, bg = ui.surface_strong })
set("PmenuKind", { fg = p.magenta, bg = ui.surface })
set("PmenuExtra", { fg = p.muted, bg = ui.surface })
set("PmenuSbar", { bg = ui.surface_strong })
set("PmenuThumb", { bg = ui.border })
set("Visual", { fg = p.fg, bg = p.selection })
link("VisualNOS", "Visual")
set("Search", { fg = p.fg, bg = ui.search })
set("CurSearch", { fg = p.bg, bg = p.blue_bright, bold = true })
link("IncSearch", "CurSearch")
set("Substitute", { fg = p.bg, bg = p.magenta, bold = true })
set("MatchParen", { fg = p.blue_bright, bg = ui.surface_strong, bold = true })
set("Folded", { fg = p.muted, bg = ui.surface })
set("FoldColumn", { fg = p.muted, bg = p.bg })
set("Whitespace", { fg = ui.border })
set("NonText", { fg = p.muted })
set("EndOfBuffer", { fg = p.bg, bg = p.bg })
set("Directory", { fg = p.blue, bold = true })
set("Title", { fg = p.blue_bright, bold = true })
set("Underlined", { fg = p.blue_bright, underline = true })
set("Todo", { fg = p.magenta, bg = ui.surface_strong, bold = true })
set("Question", { fg = p.blue_bright, bold = true })
set("MoreMsg", { fg = p.blue_bright, bold = true })
set("ModeMsg", { fg = p.blue_bright, bold = true })
set("WarningMsg", { fg = p.orange, bold = true })
set("ErrorMsg", { fg = p.red, bold = true })
set("MsgArea", { fg = p.fg, bg = p.bg })
set("WinBar", { fg = p.fg, bg = p.bg, bold = true })
set("WinBarNC", { fg = p.muted, bg = p.bg })
set("QuickFixLine", { bg = ui.surface_strong, bold = true })
set("Conceal", { fg = p.muted })

set("Comment", { fg = p.muted, italic = true })
set("Constant", { fg = p.red })
set("String", { fg = p.green })
set("Character", { fg = p.green })
set("Number", { fg = p.orange })
set("Boolean", { fg = p.red, bold = true })
set("Float", { fg = p.orange })
set("Identifier", { fg = p.fg })
set("Function", { fg = p.blue_bright })
set("Statement", { fg = p.magenta })
set("Conditional", { fg = p.magenta })
set("Repeat", { fg = p.magenta })
set("Label", { fg = p.magenta })
set("Operator", { fg = p.fg })
set("Keyword", { fg = p.magenta })
set("Exception", { fg = p.magenta })
set("PreProc", { fg = p.violet })
set("Include", { fg = p.magenta })
set("Define", { fg = p.magenta })
set("Macro", { fg = p.violet })
set("PreCondit", { fg = p.violet })
set("Type", { fg = p.purple })
set("StorageClass", { fg = p.magenta })
set("Structure", { fg = p.purple })
set("Typedef", { fg = p.purple })
set("Special", { fg = p.blue })
set("SpecialChar", { fg = p.orange })
set("Delimiter", { fg = p.fg })
set("SpecialComment", { fg = p.muted, italic = true })
set("Debug", { fg = p.orange })

link("@comment", "Comment")
link("@comment.documentation", "Comment")
link("@constant", "Constant")
link("@constant.builtin", "Constant")
link("@string", "String")
link("@string.escape", "SpecialChar")
link("@character", "Character")
link("@number", "Number")
link("@boolean", "Boolean")
link("@float", "Float")
link("@function", "Function")
link("@function.builtin", "Function")
link("@function.call", "Function")
link("@method", "Function")
link("@method.call", "Function")
link("@constructor", "Type")
link("@operator", "Operator")
link("@keyword", "Keyword")
link("@keyword.function", "Keyword")
link("@keyword.operator", "Keyword")
link("@keyword.return", "Keyword")
link("@conditional", "Conditional")
link("@repeat", "Repeat")
link("@exception", "Exception")
link("@type", "Type")
link("@type.builtin", "Type")
link("@type.definition", "Type")
link("@attribute", "PreProc")
link("@property", "Identifier")
link("@field", "Identifier")
link("@variable", "Identifier")
link("@variable.builtin", "Special")
link("@parameter", "Identifier")
link("@module", "Type")
link("@namespace", "Type")
link("@punctuation.delimiter", "Delimiter")
link("@punctuation.bracket", "Delimiter")
link("@punctuation.special", "Special")
link("@tag", "Type")
link("@tag.attribute", "Identifier")
link("@tag.delimiter", "Delimiter")
link("@markup.heading", "Title")
link("@markup.link", "Underlined")
link("@markup.raw", "String")
link("@markup.list", "Special")
link("@markup.quote", "Comment")

set("DiagnosticError", { fg = p.red })
set("DiagnosticWarn", { fg = p.orange })
set("DiagnosticInfo", { fg = p.blue_bright })
set("DiagnosticHint", { fg = p.teal })
set("DiagnosticOk", { fg = p.green })
set("DiagnosticVirtualTextError", { fg = p.red, bg = ui.diag_error })
set("DiagnosticVirtualTextWarn", { fg = p.orange, bg = ui.diag_warn })
set("DiagnosticVirtualTextInfo", { fg = p.blue_bright, bg = ui.diag_info })
set("DiagnosticVirtualTextHint", { fg = p.teal, bg = ui.diag_hint })
set("DiagnosticFloatingError", { fg = p.red })
set("DiagnosticFloatingWarn", { fg = p.orange })
set("DiagnosticFloatingInfo", { fg = p.blue_bright })
set("DiagnosticFloatingHint", { fg = p.teal })
set("DiagnosticSignError", { fg = p.red, bg = p.bg })
set("DiagnosticSignWarn", { fg = p.orange, bg = p.bg })
set("DiagnosticSignInfo", { fg = p.blue_bright, bg = p.bg })
set("DiagnosticSignHint", { fg = p.teal, bg = p.bg })
set("DiagnosticUnderlineError", { undercurl = true, sp = p.red })
set("DiagnosticUnderlineWarn", { undercurl = true, sp = p.orange })
set("DiagnosticUnderlineInfo", { undercurl = true, sp = p.blue_bright })
set("DiagnosticUnderlineHint", { undercurl = true, sp = p.teal })
set("DiagnosticDeprecated", { fg = p.muted, strikethrough = true })
set("DiagnosticUnnecessary", { fg = p.muted })
set("LspReferenceText", { bg = ui.surface_strong })
set("LspReferenceRead", { bg = ui.surface_strong })
set("LspReferenceWrite", { bg = ui.surface_strong })
set("LspSignatureActiveParameter", { fg = p.blue_bright, bold = true })
set("LspInlayHint", { fg = p.muted, bg = ui.surface })

set("DiffAdd", { bg = ui.diff_add })
set("DiffChange", { bg = ui.diff_change })
set("DiffDelete", { bg = ui.diff_delete })
set("DiffText", { bg = ui.diff_text, bold = true })

set("GitSignsAdd", { fg = p.green, bg = p.bg })
set("GitSignsChange", { fg = p.blue_bright, bg = p.bg })
set("GitSignsDelete", { fg = p.red, bg = p.bg })
set("GitSignsCurrentLineBlame", { fg = p.muted, italic = true })
set("GitSignsAddInline", { bg = ui.diff_add })
set("GitSignsChangeInline", { bg = ui.diff_change })
set("GitSignsDeleteInline", { bg = ui.diff_delete })
set("GitSignsAddPreview", { bg = ui.diff_add })
set("GitSignsDeletePreview", { bg = ui.diff_delete })
set("GitSignsDeleteVirtLn", { fg = p.red, bg = ui.diff_delete })
set("GitSignsDeleteVirtLnInline", { fg = p.red, bg = ui.diff_delete })

set("WhichKey", { fg = p.blue_bright, bold = true })
set("WhichKeyDesc", { fg = p.fg })
set("WhichKeyGroup", { fg = p.magenta, bold = true })
set("WhichKeySeparator", { fg = p.muted })
set("WhichKeyValue", { fg = p.muted })
link("WhichKeyNormal", "NormalFloat")
link("WhichKeyBorder", "FloatBorder")
link("WhichKeyTitle", "FloatTitle")
link("WhichKeyIcon", "Function")
link("WhichKeyIconAzure", "Function")
link("WhichKeyIconBlue", "DiagnosticInfo")
link("WhichKeyIconCyan", "DiagnosticHint")
link("WhichKeyIconGreen", "DiagnosticOk")
link("WhichKeyIconGrey", "Comment")
link("WhichKeyIconOrange", "DiagnosticWarn")
link("WhichKeyIconPurple", "Type")
link("WhichKeyIconRed", "DiagnosticError")
link("WhichKeyIconYellow", "DiagnosticWarn")

link("FzfLuaNormal", "NormalFloat")
link("FzfLuaBorder", "FloatBorder")
link("FzfLuaTitle", "FloatTitle")
link("FzfLuaCursorLine", "PmenuSel")
link("FzfLuaCursorLineNr", "CursorLineNr")
link("FzfLuaSearch", "Search")
link("FzfLuaPreviewNormal", "NormalFloat")
link("FzfLuaPreviewBorder", "FloatBorder")
link("FzfLuaPreviewTitle", "FloatTitle")
set("FzfLuaHeaderText", { fg = p.muted })
set("FzfLuaHeaderBind", { fg = p.magenta, bold = true })
set("FzfLuaLivePrompt", { fg = p.blue_bright, bold = true })
set("FzfLuaLiveSym", { fg = p.orange })
set("FzfLuaDirPart", { fg = p.blue_bright })
set("FzfLuaFilePart", { fg = p.fg })
set("FzfLuaPathLineNr", { fg = p.muted })
set("FzfLuaPathColNr", { fg = p.muted })
set("FzfLuaFzfNormal", { fg = p.fg, bg = ui.surface })
set("FzfLuaFzfBorder", { fg = ui.border, bg = ui.surface })
set("FzfLuaFzfCursorLine", { bg = ui.surface_strong })
set("FzfLuaFzfGutter", { bg = ui.surface })
set("FzfLuaFzfHeader", { fg = p.muted })
set("FzfLuaFzfInfo", { fg = p.muted })
set("FzfLuaFzfMarker", { fg = p.magenta, bold = true })
set("FzfLuaFzfMatch", { fg = p.blue_bright, bold = true })
set("FzfLuaFzfPointer", { fg = p.blue_bright, bold = true })
set("FzfLuaFzfPrompt", { fg = p.blue_bright, bold = true })
set("FzfLuaFzfQuery", { fg = p.fg })
set("FzfLuaFzfScrollbar", { fg = ui.border })
set("FzfLuaFzfSeparator", { fg = ui.border })
