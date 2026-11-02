-- GitHub Enterprise base URLs, read from the environment so internal hostnames stay out of this
-- repo. Export GITHUB_ENTERPRISE_URL (for example https://github.example.com) in your shell, and
-- separate several servers with commas. github.com needs no setup.
local function github_enterprise_urls()
  return vim
    .iter(vim.split(vim.env.GITHUB_ENTERPRISE_URL or "", ","))
    :map(function(url)
      return (vim.trim(url):gsub("/+$", ""))
    end)
    :filter(function(url)
      return url ~= ""
    end)
    :totable()
end

-- Returns the Enterprise hostname used by the current repository's remotes, or "" for github.com
-- and anything else.
local function github_enterprise_host_for_cwd()
  local remotes = vim.system({ "git", "remote", "-v" }, { text = true }):wait().stdout or ""
  for _, url in ipairs(github_enterprise_urls()) do
    local host = url:gsub("^%a+://", ""):gsub("/.*$", "")
    if host ~= "" and remotes:find(host, 1, true) then
      return host
    end
  end
  return ""
end

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
      local urls = github_enterprise_urls()
      if #urls > 0 then
        vim.g.github_enterprise_urls = urls
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
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>gp", "<cmd>Octo pr<CR>", desc = "Open this branch's PR" },
      { "<leader>gP", "<cmd>Octo pr list<CR>", desc = "Pick a PR" },
      { "<leader>gr", "<cmd>Octo review browse<CR>", desc = "Browse PR diff and threads" },
      { "<leader>gR", "<cmd>Octo review<CR>", desc = "Start or resume a review" },
    },
    opts = function()
      return {
        picker = "telescope",
        enable_builtin = true, -- bare :Octo opens a picker of every command
        -- Octo sends every request to github_hostname when it is set, and otherwise to the host
        -- of the repo's remote. Set it only inside Enterprise repos, so github.com repos keep
        -- working and Octo leaves out github.com-only fields older Enterprise servers reject.
        github_hostname = github_enterprise_host_for_cwd(),
        -- Plain-text markers in place of Octo's Nerd Font defaults.
        user_icon = "@",
        ghost_icon = "@",
        copilot_icon = "@",
        dependabot_icon = "@",
        reaction_viewer_hint_icon = "* ",
        outdated_icon = "[outdated] ",
        resolved_icon = "[resolved] ",
        use_timeline_icons = false,
        timeline_marker = "-",
        left_bubble_delimiter = "",
        right_bubble_delimiter = "",
        file_panel = { icons = false },
      }
    end,
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
