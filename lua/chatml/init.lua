---@class ChatML
local M = {}

---Setup the chatml plugin
---@param opts ChatMLOptions: plugin options table
M.setup = function(opts)
  require("chatml.config").setup(opts)
end

return M
