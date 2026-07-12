return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon",
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")

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
          if ok then
            highlight.bg = nil
            highlight.ctermbg = nil
            vim.api.nvim_set_hl(0, group, highlight)
          end
        end
      end

      clear_backgrounds()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("transparent_background", { clear = true }),
        callback = clear_backgrounds,
      })
    end,
  },
}
