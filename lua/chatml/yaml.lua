--[[
This is code is from olimorris/codecompanion.nvim repo:
  https://github.com/olimorris/codecompanion.nvim/blob/afe9bd7fb8b1e4388458f21d7ba1671681c0bade/lua/codecompanion/utils/yaml.lua#L1-L114

Check out NOTICE.md for more information about the original code.
--]]

local M = {}

M.encode = function(data)
  local dt = type(data)
  if data == nil then
    return "null"
  elseif dt == "number" then
    if data % 1 == 0 then
      return string.format("%d", data)
    else
      return string.format("%.3f", data) -- NOTE: float conversion is not accurate
    end
  elseif dt == "boolean" then
    return string.format("%s", data)
  elseif dt == "string" then
    if data == "yes" or data == "no" or data == "true" or data == "false" or data == "on" or data == "off" then
      return string.format('"%s"', data)
    else
      return data
    end
  elseif dt == "table" then
    local lines = {}
    if vim.islist(data) then
      if vim.tbl_isempty(data) then
        return "[]"
      else
        for _, v in ipairs(data) do
          table.insert(lines, string.format("- %s", M.encode(v)))
        end
      end
    else
      if vim.tbl_isempty(data) then
        return "{}"
      else
        local sorted_keys = {}
        for k in pairs(data) do
          table.insert(sorted_keys, k)
        end
        table.sort(sorted_keys)
        for _, k in ipairs(sorted_keys) do
          table.insert(lines, string.format("%s: %s", k, M.encode(data[k])))
        end
      end
    end
    return table.concat(lines, "\n")
  else
    error(string.format("Cannot encode type '%s' to yaml", dt))
  end
end

local function decode(source, node)
  local nt = node:type()
  if nt == "stream" or nt == "document" or nt == "block_node" or nt == "flow_node" or nt == "plain_scalar" then
    for child in node:iter_children() do
      if child:named() then
        return decode(source, child)
      end
    end
  elseif nt == "block_mapping" then
    local result = {}
    for child in node:iter_children() do
      assert(child:type() == "block_mapping_pair")
      local key = decode(source, child:named_child(0))
      if not key then
        error("Could not decode map key")
      end
      result[key] = decode(source, child:named_child(1))
    end
    -- Provide a way to get the TSNode for a map
    return setmetatable(result, {
      __index = {
        __ts_node = node,
      },
    })
  elseif nt == "flow_sequence" or nt == "block_sequence" then
    local ret = {}
    for child in node:iter_children() do
      if child:named() then
        table.insert(ret, decode(source, child))
      end
    end
    return ret
  elseif nt == "string_scalar" then
    return vim.treesitter.get_node_text(node, source)
  elseif nt == "single_quote_scalar" or nt == "double_quote_scalar" then
    local text = vim.treesitter.get_node_text(node, source)
    return text:sub(2, text:len() - 1)
  elseif nt == "integer_scalar" or nt == "float_scalar" then
    return tonumber(vim.treesitter.get_node_text(node, source))
  elseif nt == "null_scalar" then
    return nil
  elseif nt == "boolean_scalar" then
    local text = vim.treesitter.get_node_text(node, source)
    if text == "true" then
      return true
    elseif text == "false" then
      return false
    else
      error("Invalid boolean scalar")
    end
  elseif nt == "ERROR" then
    -- TODO should probably annotate this and pass it up somehow
    return nil
  else
    error(string.format("Unknown yaml node type '%s'", nt))
  end
end

M.decode_node = function(source, node)
  return decode(source, node)
end

M.decode = function(str)
  local lang_tree = vim.treesitter.get_string_parser(str, "yaml", { injections = { yaml = "" } })
  local root = lang_tree:parse()[1]:root()
  return decode(str, root)
end

return M
