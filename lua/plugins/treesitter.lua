return {
  {
    "romus204/tree-sitter-manager.nvim",
    lazy = false,
    config = function()
      if vim.fn.executable("tree-sitter") ~= 1 then
        vim.notify(
          "tree-sitter CLI is not installed; external parser installation is disabled. "
            .. "See README.md, then restart Neovim.",
          vim.log.levels.WARN
        )
        return
      end

      local all_parsers = require("config.languages").parsers()
      local builtin = {
        c = true,
        lua = true,
        markdown = true,
        markdown_inline = true,
        query = true,
        vim = true,
        vimdoc = true,
      }
      local install = {}
      local assumed = {}

      for parser in pairs(builtin) do
        assumed[#assumed + 1] = parser
      end
      table.sort(assumed)

      for _, parser in ipairs(all_parsers) do
        if not builtin[parser] then
          install[#install + 1] = parser
        end
      end

      require("tree-sitter-manager").setup({
        assume_installed = assumed,
        ensure_installed = install,
        auto_install = true,
        noauto_install = assumed,
        highlight = true,
        nerdfont = false,
        border = "rounded",
      })
    end,
  },
}
