-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
  return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
  return
end

-- import typescript plugin safely
local typescript_setup, typescript = pcall(require, "typescript")
if not typescript_setup then
  return
end

local keymap = vim.keymap -- for conciseness

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
  -- keybind options
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- set keybinds
  keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", opts) -- show definition, references
  keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- got to declaration
  keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
  keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- go to implementation
  keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
  keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
  keymap.set("n", "<leader>d", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
  keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
  keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
  keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
  keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor
  keymap.set("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", opts) -- see outline on right hand side

  -- typescript specific keymaps (e.g. rename file and update imports)
  if client.name == "tsserver" then
    keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- rename file and update imports
    keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- organize imports (not in youtube nvim video)
    keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- remove unused variables (not in youtube nvim video)
  end
end

-- used to enable autocompletion (assign to every lsp server config)
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- configure html server
lspconfig["html"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure typescript server with plugin
typescript.setup({
  server = {
    capabilities = capabilities,
    on_attach = on_attach,
  },
})

-- configure css server
lspconfig["cssls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure tailwindcss server
lspconfig["tailwindcss"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure emmet language server
lspconfig["emmet_ls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
})

-- configure lua server (with special settings)
lspconfig["sumneko_lua"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = { -- custom settings for lua
    Lua = {
      -- make the language server recognize "vim" global
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        -- make language server aware of runtime files
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    },
  },
})

-- require("clangd_extensions").setup {
--     server = {
--         -- options to pass to nvim-lspconfig
--         require("lspconfig").clangd.setup({})
--     },
--     extensions = {
--         -- defaults:
--         -- Automatically set inlay hints (type hints)
--         autoSetHints = true,
--         -- These apply to the default ClangdSetInlayHints command
--         inlay_hints = {
--             -- Only show inlay hints for the current line
--             only_current_line = false,
--             -- Event which triggers a refersh of the inlay hints.
--             -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
--             -- not that this may cause  higher CPU usage.
--             -- This option is only respected when only_current_line and
--             -- autoSetHints both are true.
--             only_current_line_autocmd = "CursorHold",
--             -- whether to show parameter hints with the inlay hints or not
--             show_parameter_hints = true,
--             -- prefix for parameter hints
--             parameter_hints_prefix = "<- ",
--             -- prefix for all the other hints (type, chaining)
--             other_hints_prefix = "=> ",
--             -- whether to align to the length of the longest line in the file
--             max_len_align = false,
--             -- padding from the left if max_len_align is true
--             max_len_align_padding = 1,
--             -- whether to align to the extreme right or not
--             right_align = false,
--             -- padding from the right if right_align is true
--             right_align_padding = 7,
--             -- The color of the hints
--             highlight = "Comment",
--             -- The highlight group priority for extmark
--             priority = 100,
--         },
--         ast = {
--             -- These are unicode, should be available in any font
--             role_icons = {
--                  type = "🄣",
--                  declaration = "🄓",
--                  expression = "🄔",
--                  statement = ";",
--                  specifier = "🄢",
--                  ["template argument"] = "🆃",
--             },
--             kind_icons = {
--                 Compound = "🄲",
--                 Recovery = "🅁",
--                 TranslationUnit = "🅄",
--                 PackExpansion = "🄿",
--                 TemplateTypeParm = "🅃",
--                 TemplateTemplateParm = "🅃",
--                 TemplateParamObject = "🅃",
--             },
--             --[[ These require codicons (https://github.com/microsoft/vscode-codicons)
--             role_icons = {
--                 type = "",
--                 declaration = "",
--                 expression = "",
--                 specifier = "",
--                 statement = "",
--                 ["template argument"] = "",
--             },
--
--             kind_icons = {
--                 Compound = "",
--                 Recovery = "",
--                 TranslationUnit = "",
--                 PackExpansion = "",
--                 TemplateTypeParm = "",
--                 TemplateTemplateParm = "",
--                 TemplateParamObject = "",
--             }, ]]
--
--             highlights = {
--                 detail = "Comment",
--             },
--         },
--         memory_usage = {
--             border = "none",
--         },
--         symbol_info = {
--             border = "none",
--         },
--     },
-- }
