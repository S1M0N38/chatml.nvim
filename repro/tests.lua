#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local plugins = {
  {
    "S1M0N38/chatml.nvim",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
          ensure_installed = { "markdown", "markdown_inline", "yaml", "json" },
        },
      },
    },
  },
}

-- Setup lazy.nvim
require("lazy.minit").busted({ spec = plugins })

vim.cmd("checkhealth")
