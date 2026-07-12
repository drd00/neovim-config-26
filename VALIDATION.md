# Validation notes

The delivered files were checked as follows:

- every Lua file was parsed successfully with `luaparser`;
- the Ubuntu installer passed `bash -n`;
- the language-registry aggregation functions were executed with a Lua runtime;
- the generated server and parser lists are sorted and contain no duplicates;
- every declared parser name exists in the current `tree-sitter-manager.nvim` repository table;
- every declared LSP name exists in the current `mason-lspconfig.nvim` mappings;
- the Neovim version and Linux archive SHA-256 values in the installer match the official Neovim 0.12.4 release assets;
- legacy entries involved in the previous failures (`ruff_format`, `jsonc`, and custom Mason sync commands) are absent.

A full first-launch test was not possible in the build container because it does not contain Neovim or unrestricted GitHub network access. The config therefore avoids custom installation APIs and follows the documented setup interfaces of lazy.nvim, Mason, mason-lspconfig, nvim-lspconfig, and tree-sitter-manager.nvim.
