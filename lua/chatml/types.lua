---@meta
--- This is a simple "definition file" (https://luals.github.io/wiki/definition-files/),
--- the @meta tag at the top is its hallmark.

-- NOTE: ChatML prefix is used to types from chatml.nvim types

-- NOTE: These files are not annotated with types. The code is from external sources.
--  lua/chatml/yaml.lua
--  lua/chatml/log.lua

-- lua/chatml/init.lua -----------------------------------------------------------

---@class ChatML
---@field setup fun(opts: ChatMLOptions): nil

-- lua/chatml/config.lua ---------------------------------------------------------

---@class ChatMLConfig
---@field defaults ChatMLOptions default options
---@field options ChatMLOptions user options
---@field setup fun(opts: ChatMLOptions): nil

---@class ChatMLOptions

-- lua/chatml/health.lua ---------------------------------------------------------

---@class ChatMLHealth
---@field check fun(): nil

-- lua/chatml/parse.lua ---------------------------------------------------------

---@class ChatMLParse
---@field json_to_md fun(json_str: string): string
---@field json_buf_to_md_buf fun(in_buf: integer, out_buf: integer?): integer
---@field md_to_json fun(md_str: string): string
---@field md_buf_to_json_buf fun(in_buf: integer, out_buf: integer?): integer

-- lua/chatml/llm.lua -----------------------------------------------------------

---@class ChatMLLLM
---@field client AiClient: llm client used to set request to provider
---@field chat_completion fun(in_buf: integer, out_buf: integer?): nil

---------------------------------------------------------------------------------
