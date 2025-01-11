-- repro/repro.lua serves as a reproducible environment for your plugin.
-- Whwn user want to open a new ISSUE, they are asked to reproduce their issue in a clean minial environment.
-- repro directory is a safe place to mess around with various config without affecting your main setup.
--
-- 1. Clone chatml.nvim and cd into chatml.nvim/repro
-- 2. Run `nvim -u repro/repro.lua`
-- 3. Reproduce the issue
-- 4. Report the repro.lua and logs from .repro directory in the issue
--

vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local plugins = {
  {
    "S1M0N38/chatml.nvim",
    lazy = false,
    opts = {},
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
          ensure_installed = { "markdown", "markdown_inline", "yaml", "json" },
          highlight = { enable = true },
        },
      },
      {
        "S1M0N38/ai.nvim",
        version = ">=1.4.2",
        opts = {

          --NOTE: select one of the following providers:
          --https://github.com/S1M0N38/ai.nvim?tab=readme-ov-file#-llm-providers

          -- -- OpenAI provider
          -- base_url = "https://api.openai.com/v1",
          -- api_key = "sk-xxx",

          -- -- Copilot provider
          -- base_url = "https://api.githubcopilot.com",
          -- copilot = true,

          -- -- Local provider
          -- base_url = "http://localhost:1234/v1",
          -- api_key = "here-is-a-dummy-api-key",
        },
      },
    },
  },

  keys = {
    {
      "<S-CR>",
      function()
        require("chatml.llm").chat_completion(vim.api.nvim_get_current_buf())
      end,
      desc = "Send requests to LLM",
      ft = "markdown",
      mode = { "n" },
    },
    {
      "<C-CR>",
      function()
        require("chatml.parse").md_buf_to_json_buf(0, 0)
        -- vim.cmd("LspRestart") -- maybe LSP need to be restarted
      end,
      desc = "Convert from markdown to JSON",
      ft = "markdown",
      mode = { "n" },
    },
    {
      "<C-CR>",
      function()
        require("chatml.parse").json_buf_to_md_buf(0, 0)
        -- vim.cmd("LspRestart") -- maybe LSP need to be restarted
      end,
      desc = "Convert from JSON to markdown",
      ft = "json",
      mode = { "n" },
    },
  },
}

require("lazy.minit").repro({ spec = plugins })

-- Add additional setup here ...

-- RESOURCES:
--   - https://lazy.folke.io/developers#reprolua
