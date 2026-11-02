return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files({ hidden = true })
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Find buffers",
      },
      {
        "<leader>fh",
        function()
          require("telescope.builtin").help_tags()
        end,
        desc = "Help tags",
      },
      {
        "<leader>fr",
        function()
          require("telescope.builtin").oldfiles()
        end,
        desc = "Recent files",
      },
    },
    opts = {
      defaults = {
        border = true,
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gedit", "GBrowse" },
    dependencies = { "tpope/vim-rhubarb" },
    init = function()
      -- Rhubarb recognises github.com remotes out of the box. For GitHub Enterprise,
      -- export GITHUB_ENTERPRISE_URL (for example https://github.example.com, or a
      -- comma-separated list) in your shell so the hostname stays out of this repo.
      local enterprise_urls = vim.env.GITHUB_ENTERPRISE_URL
      if enterprise_urls and enterprise_urls ~= "" then
        vim.g.github_enterprise_urls = vim.split(enterprise_urls, ",", { trimempty = true })
      end
    end,
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git status" },
      { "<leader>gd", "<cmd>Gvdiffsplit<CR>", desc = "Diff against index" },
      { "<leader>go", "<cmd>.GBrowse<CR>", desc = "Open line on GitHub" },
      { "<leader>go", ":GBrowse<CR>", mode = "x", desc = "Open selection on GitHub" },
      { "<leader>gy", "<cmd>.GBrowse!<CR>", desc = "Copy GitHub link to line" },
      { "<leader>gy", ":GBrowse!<CR>", mode = "x", desc = "Copy GitHub link to selection" },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "|",
        section_separators = "",
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 300,
      preset = "modern",
      icons = { mappings = false },
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lsp" },
        { "<leader>t", group = "toggle/terminal" },
      },
    },
  },
}
