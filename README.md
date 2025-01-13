<div align="center">
  <h1>⇋&nbsp;&nbsp;chatml.nvim&nbsp;&nbsp;<a href="https://github.com/S1M0N38/ai.nvim">✧</a></h1>
  <p align="center">
     <a href="https://github.com/S1M0N38/chatml.nvim/actions/workflows/run-tests.yml">
     <img alt="Tests workflow" src="https://img.shields.io/github/actions/workflow/status/S1M0N38/chatml.nvim/run-tests.yml?style=for-the-badge&label=Tests"/>
     </a>
     <a href="https://luarocks.org/modules/S1M0N38/chatml.nvim">
     <img alt="LuaRocks release" src="https://img.shields.io/luarocks/v/S1M0N38/chatml.nvim?style=for-the-badge&color=5d2fbf"/>
     </a>
     <a href="https://github.com/S1M0N38/chatml.nvim/releases">
     <img alt="GitHub release" src="https://img.shields.io/github/v/release/S1M0N38/chatml.nvim?style=for-the-badge&label=GitHub"/>
     </a>
     <a href="https://www.reddit.com/r/neovim/comments/1i0bq49/chatmlnvim_convert_markdown_to_llm_json_requests/">
     <img alt="Reddit post" src="https://img.shields.io/badge/post-reddit?style=for-the-badge&label=Reddit&color=FF5700"/>
     </a>
  </p>
  <div><img src="https://github.com/user-attachments/assets/85ccd14f-58bd-4ce9-a1a7-a9c62d525cdf" alt="Screencast: chatml.nvim example usage"></div>
  <p><em>OpenAI chat completion request (JSON) ⇋ markdown & sent requests</em></p>
  <hr>
</div>

## 💡 Idea

chatml.nvim is a simple Neovim plugin for working with LLM chat completion requests. It provides bidirectional conversion between two formats:

- A human-friendly markdown format: readable and easy to edit and navigate
- The JSON format required by OpenAI-compatible APIs

It follows the [chat-completion-md](https://github.com/S1M0N38/chat-completion-md) specification.

While the plugin can send requests to LLM providers, it keeps a modest scope. It doesn't try to be context-aware or integrate with your development environment. Instead, it's just a playground for experimenting with prompts, letting you focus on crafting and refining your LLM interactions.

Think of it as a basic text converter with optional LLM integration, not a comprehensive AI coding assistant.


## ⚡️ Requirements

- Neovim ≥ **0.10**
- [cURL](https://curl.se/) (optional)
- Access to an [OpenAI compatible API](https://github.com/S1M0N38/ai.nvim?tab=readme-ov-file#-llm-providers) (optional)

## 📦 Installation

You can install chatml.nvim using your preferred plugin manager. Here's an example configuration for lazy.nvim:


```lua
-- Using lazy.nvim
{
  "S1M0N38/chatml.nvim",
  version = "*",
  opts = {},
  dependencies = {
    {
      -- (Required) Used for parsing various formats
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      opts = {
        ensure_installed = { "markdown", "markdown_inline", "yaml", "json" },
      },
    },
    {
      -- (Optional) It is required for sending requests to LLM providers
      "S1M0N38/ai.nvim",
      version = ">=1.4.2",
      opts = {
        -- (Required) Configure a provider. :help ai-setup or
        -- https://github.com/S1M0N38/ai.nvim/blob/main/doc/ai.txt
      },
    },
  },
  keys = {
    {
      "<leader>fa",
      function()
        --- Setup prompts search for your preferred picker. For LazyVim, use:
        LazyVim.pick("files", { cwd = "path/to/prompts/directory" })()
      end,
      desc = "Find ai-prompts (chatml)",
      mode = { "n" },
    },
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
        vim.cmd("LspRestart")
        -- 2 space indentation for JSON in LazyVim:
        LazyVim.format({ force = true })
      end,
      desc = "Convert from markdown to JSON",
      ft = "markdown",
      mode = { "n" },
    },
    {
      "<C-CR>",
      function()
        require("chatml.parse").json_buf_to_md_buf(0, 0)
        vim.cmd("LspRestart")
      end,
      desc = "Convert from JSON to markdown",
      ft = "json",
      mode = { "n" },
    },
  },
}
```

## 🚀 Usage

To get started with chatml.nvim, read the documentation with [`:help chatml`](https://github.com/S1M0N38/chatml.nvim/blob/main/doc/chatml.txt). This will provide you with a comprehensive overview of the plugin's features and usage.

> [!NOTE]
> **Learning Vim/Neovim Documentation**: Vim/Neovim plugins are usually shipped with :help documentation. Learning how to navigate it is a valuable skill. If you are not familiar with it, start with `:help` and read the first 20 lines.


## 🙏 Acknowledgments

- [olimorris/codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) tree-sitter yaml parser.
- [tjdevries/vlog.nvim](https://github.com/tjdevries/vlog.nvim) for logging.
- [S1M0N38/chat-completion-md](https://github.com/S1M0N38/chat-completion-md) for conversion specification.
- [S1M0N38/base.nvim](https://github.com/S1M0N38/base.nvim) for template.
- [S1M0N38/ai.nvim](https://github.com/S1M0N38/ai.nvim) for LLM providers.
- [mrcjkb](https://github.com/nvim-neorocks/nvim-busted-action/discussions/8) for GitHub Actions help.
