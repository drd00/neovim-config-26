return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      {
        "mason-org/mason.nvim",
        lazy = false,
        opts = {
          PATH = "prepend",
          ui = { border = "rounded" },
        },
      },
      {
        "mason-org/mason-lspconfig.nvim",
        lazy = false,
      },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local languages = require("config.languages")
      local servers = languages.servers()
      local server_names = languages.server_names()

      require("mason-lspconfig").setup({
        ensure_installed = server_names,
        automatic_enable = false,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      for name, options in pairs(servers) do
        vim.lsp.config(name, vim.tbl_deep_extend("force", {
          capabilities = capabilities,
        }, options))
      end

      -- Explicit activation also supports servers installed outside Mason.
      for _, name in ipairs(server_names) do
        vim.lsp.enable(name)
      end

      vim.diagnostic.config({
        severity_sort = true,
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 3,
          source = "if_many",
        },
        float = {
          border = "rounded",
          source = true,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.INFO] = "I",
            [vim.diagnostic.severity.HINT] = "H",
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true }),
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, {
              buf = args.buf,
              desc = "LSP: " .. desc,
            })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("gr", vim.lsp.buf.references, "Find references")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>ls", vim.lsp.buf.signature_help, "Signature help")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format buffer")

          if client:supports_method("textDocument/inlayHint") then
            map("<leader>th", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = args.buf })
            end, "Toggle inlay hints")
          end

          if client:supports_method("textDocument/documentHighlight") then
            local highlight_group = vim.api.nvim_create_augroup(
              "lsp_document_highlight_" .. args.buf,
              { clear = true }
            )
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = highlight_group,
              buffer = args.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = highlight_group,
              buffer = args.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      vim.keymap.set("n", "<leader>cm", "<cmd>Mason<CR>", { desc = "Mason" })
      vim.keymap.set("n", "<leader>ci", "<cmd>LspInfo<CR>", { desc = "LSP info" })
    end,
  },
}
