---@class ChatMLHealth
local M = {}

---Validate the options table obtained from merging defaults and user options
local function check_opts_table()
  local _ = require("chatml.config").options

  local ok, err = pcall(function()
    vim.validate({
      -- At the moment, there is not key in config table
      -- name = { opts.name, "string" }
      --- validate other options here...
    })
  end)

  if not ok then
    vim.health.error("Invalid setup options: " .. err)
  else
    vim.health.ok("Setup options are correctly set")
  end
end

---Check for dependencies
local function check_dependencies()
  local ok

  --- Check for ai.nvim
  ok, _ = pcall(require, "ai")
  if not ok then
    vim.health.error("ai.nvim is not installed")
  else
    vim.health.ok("ai.nvim is installed")
  end

  --- Check for TreeSitter
  ok, _ = pcall(require, "nvim-treesitter")
  if not ok then
    vim.health.error("TreeSitter is not installed")
  else
    vim.health.ok("TreeSitter is installed")
  end
end

---Check for suggested TreeSitter parsers
local function check_ts_parsers()
  local ts = require("nvim-treesitter.parsers")
  local parsers = ts.available_parsers()
  local required_parsers = { "markdown", "markdown_inline", "yaml", "json" }
  for _, parser in ipairs(required_parsers) do
    if vim.tbl_contains(parsers, parser) then
      vim.health.ok(parser .. " parser for TreeSitter is installed")
    else
      vim.health.error(parser .. " parser for TreeSitter is not installed")
    end
  end
end

---This function is used to check the health of the plugin
---It's called by `:checkhealth` command
M.check = function()
  vim.health.start("chatml.nvim health check")

  check_opts_table()
  check_dependencies()
  check_ts_parsers()
end

return M
