---@class ChatMLConfig
local M = {}

-- NOTE: chatml.nvim does not define any options at the moment.

---@class ChatMLOptions
M.defaults = {}

---@class ChatMLOptions
M.options = {}

---Extend the defaults options table with the user options
---@param opts ChatMLOptions: plugin options
M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
