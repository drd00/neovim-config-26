return {
  {
    "vague-theme/vague.nvim",
    lazy = false,
    priority = 1000,

    opts = {
      transparent = true,
      bold = true,

      -- Vague's italic option affects several kinds of syntax, including
      -- strings. Disable that global behavior, then enable italics only
      -- for comments and keywords below.
      italic = false,

      on_highlights = function(hl)
        local italic_groups = {
          -- Comments
          "Comment",
          "SpecialComment",

          -- Vim syntax keyword groups
          "Keyword",
          "Conditional",
          "Exception",
          "Include",
          "Label",
          "PreProc",
          "Repeat",
          "Statement",

          -- Vague defines this Tree-sitter capture separately,
          -- so it will not inherit Keyword's italics.
          "@keyword.return",
        }

        for _, group in ipairs(italic_groups) do
          if hl[group] then
            hl[group].italic = true
          end
        end
      end,
    },

    config = function(_, opts)
      require("vague").setup(opts)
      vim.cmd.colorscheme("vague")

      -- Force transparency for UI/plugin groups that may retain
      -- their own backgrounds.
      local groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "SignColumn",
        "FoldColumn",
        "EndOfBuffer",
        "LineNr",
        "CursorLineNr",
        "StatusLine",
        "StatusLineNC",
        "WinBar",
        "WinBarNC",
        "Pmenu",
        "PmenuSbar",
        "TelescopeNormal",
        "TelescopeBorder",
        "TelescopePromptNormal",
        "TelescopeResultsNormal",
        "TelescopePreviewNormal",
        "WhichKeyNormal",
        "MasonNormal",
        "LazyNormal",
      }

      local function clear_backgrounds()
        for _, group in ipairs(groups) do
          local ok, highlight = pcall(vim.api.nvim_get_hl, 0, {
            name = group,
            link = false,
          })

          -- Avoid creating empty highlight definitions for groups
          -- that do not currently exist.
          if ok and next(highlight) ~= nil then
            highlight.bg = nil
            highlight.ctermbg = nil
            vim.api.nvim_set_hl(0, group, highlight)
          end
        end
      end

      local transparent_group = vim.api.nvim_create_augroup(
        "transparent_background",
        { clear = true }
      )

      clear_backgrounds()

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = transparent_group,
        callback = clear_backgrounds,
        desc = "Keep Neovim UI backgrounds transparent",
      })
    end,
  },
}
