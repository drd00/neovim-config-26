local M = {}

-- Add a language here and both LSP installation/activation and Tree-sitter
-- parser installation will pick it up. No other file needs to be edited.
M.languages = {
  core = {
    parsers = { "lua", "vim", "vimdoc", "query" },
  },

  c_cpp = {
    parsers = { "c", "cpp" },
    servers = {
      clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
        },
      },
    },
  },

  rust = {
    parsers = { "rust" },
    servers = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
          },
        },
      },
    },
  },

  lua = {
    parsers = { "lua" },
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      },
    },
  },

  python = {
    parsers = { "python" },
    servers = {
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "basic",
              useLibraryCodeForTypes = true,
            },
          },
        },
      },
    },
  },

  go = {
    parsers = { "go", "gomod", "gosum", "gowork" },
    servers = {
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
            usePlaceholders = true,
          },
        },
      },
    },
  },

  shell = {
    -- bash-language-server is deprecated upstream, so this config keeps
    -- Tree-sitter shell highlighting without installing an abandoned LSP.
    parsers = { "bash" },
  },

  web = {
    parsers = { "javascript", "typescript", "tsx", "html", "css" },
    servers = {
      ts_ls = {},
      html = {},
      cssls = {},
    },
  },

  data = {
    parsers = { "json", "yaml", "toml" },
    servers = {
      jsonls = {},
      yamlls = {
        settings = {
          yaml = {
            keyOrdering = false,
          },
        },
      },
      taplo = {},
    },
  },

  markdown = {
    parsers = { "markdown", "markdown_inline" },
    servers = {
      marksman = {},
    },
  },

  docker = {
    parsers = { "dockerfile" },
    servers = {
      dockerls = {},
    },
  },
}

local function sorted_keys(values)
  local result = {}
  for key in pairs(values) do
    result[#result + 1] = key
  end
  table.sort(result)
  return result
end

function M.servers()
  local result = {}
  for _, language in pairs(M.languages) do
    for name, options in pairs(language.servers or {}) do
      result[name] = options
    end
  end
  return result
end

function M.server_names()
  return sorted_keys(M.servers())
end

function M.parsers()
  local seen = {}
  for _, language in pairs(M.languages) do
    for _, parser in ipairs(language.parsers or {}) do
      seen[parser] = true
    end
  end
  return sorted_keys(seen)
end

return M
