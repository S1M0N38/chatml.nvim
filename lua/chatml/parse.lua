local log = require("chatml.log")
local yaml = require("chatml.yaml")

---@class ChatMLParse
local M = {}

----------------------------------------------------------------------------------------------------
-- JSON to Markdown
----------------------------------------------------------------------------------------------------

---Convert JSON string of chat completion request to markdown
---It follow the specification of https://github.com/S1M0N38/chat-completion-md
---@param json_str string: JSON string of chat completion request
---@return string|nil: markdown string of chat completion request
M.json_to_md = function(json_str)
  -- Parse the JSON string
  local ok, json_data = pcall(vim.json.decode, json_str, { luanil = { object = true, array = true } })
  if not ok then
    log.debug("Invalid JSON string")
    error("Invalid JSON string")
  end

  -- Check for and extract the "messages" key
  local messages = json_data["messages"]
  if not messages then
    log.debug("Messages key not found in JSON")
    error("Messages key not found in JSON")
  end

  -- Check for "model" key
  if not json_data["model"] then
    log.debug("Model key not found in JSON")
    error("Model key not found in JSON")
  end

  -- Validate "messages" and roles
  local valid_roles = { assistant = true, developer = true, system = true, tool = true, user = true }
  for _, msg in ipairs(messages) do
    if type(msg) ~= "table" or not msg.role or not msg.content then
      log.debug("Each message must be a table with 'role' and 'content' keys")
      error("Each message must be a table with 'role' and 'content' keys")
    end
    if not valid_roles[msg.role] then
      log.debug("Invalid role: " .. tostring(msg.role))
      error("Invalid role: " .. tostring(msg.role))
    end
  end

  --- Parse metadata as yaml
  json_data["messages"] = nil
  local metadata_str = yaml.encode(json_data):gsub("^%s+", ""):gsub("%s+$", "")

  --- Generate markdown string
  local md_str = "---\n" .. metadata_str .. "\n---\n"
  for _, msg in ipairs(messages) do
    md_str = md_str .. "\n# " .. msg.role .. "\n\n" .. msg.content .. "\n\n---\n"
  end
  md_str = md_str:gsub("%s+$", "")

  return md_str
end

---Convert JSON buffer to markdown buffer using json_to_md
---@param in_buf number: input JSON buffer number
---@param out_buf number?: output markdown buffer number
---@return number|nil: output markdown buffer number
M.json_buf_to_md_buf = function(in_buf, out_buf)
  local in_ft = vim.api.nvim_get_option_value("filetype", { buf = in_buf })
  if in_ft ~= "json" then
    log.debug("Buffer is not a JSON buffer")
    error("Buffer is not a JSON buffer")
  end
  local json_str = table.concat(vim.api.nvim_buf_get_lines(in_buf, 0, -1, false), "\n")
  local md_str = M.json_to_md(json_str)
  if md_str then
    out_buf = out_buf or vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = out_buf })
    vim.api.nvim_buf_set_lines(out_buf, 0, -1, false, vim.split(md_str, "\n"))
  else
    log.debug("Generated md_str is nil")
    error("Generated md_str is nil")
  end
end

----------------------------------------------------------------------------------------------------
-- Markdown to JSON
----------------------------------------------------------------------------------------------------

---Convert markdown string of chat completion request to JSON
---It follow the specification of https://github.com/S1M0N38/chat-completion-md
---@param md_str string: markdown string of chat completion request
---@return string|nil: JSON string of chat completion request.
M.md_to_json = function(md_str)
  -- Extract front matter and content using pattern matching
  local front_matter, content = md_str:match("^%-%-%-\n(.-)\n%-%-%-(.*)$")

  if not front_matter or #front_matter == 0 then
    log.debug("Cannot parse Markdown string")
    error("Cannot parse Markdown string")
  end

  -- Parse YAML front matter
  local ok, config = pcall(yaml.decode, front_matter)
  if not ok then
    log.debug("Cannot parse front matter YAML")
    error("Cannot parse front matter YAML")
  end

  log.debug("config: ", config)

  if config == nil then
    log.debug("Parsed (yaml) config is nil")
    error("Parsed (yaml) config is nil")
  end

  if config ~= nil or not config.model then
    log.debug("Model key not found in front matter")
    error("Model key not found in front matter")
  end

  if #content == 0 then
    log.debug("Content after front matter is empty")
    error("Content after front matter is empty")
  end

  -- Extract messages using pattern matching
  local messages = {}
  local roles = { "system", "user", "assistant", "developer", "tool" }
  local pattern = "\n# (%w+)\n\n(.-)\n\n%-%-%-"

  -- Parse each message block ending with ---
  for role, msg_content in content:gmatch(pattern) do
    if vim.tbl_contains(roles, role) then
      table.insert(messages, {
        role = role,
        content = msg_content,
      })
    else
      log.debug("Invalid role: " .. role)
      error("Invalid role: " .. role)
    end
  end

  log.debug("messages: ", messages)

  if #messages == 0 then
    log.debug("No messages found")
    error("No messages found")
  end

  -- Combine config and messages
  config.messages = messages

  -- Encode to JSON string
  local json_str_ok, json_str = pcall(vim.json.encode, config)
  if not json_str_ok then
    log.debug("Cannot encode table to json string")
    error("Cannot encode table to json string")
  end

  return json_str
end

---Convert markdown buffer to JSON buffer using md_to_json
---@param in_buf number: input markdown buffer number
---@param out_buf number?: output JSON buffer number
---@return number|nil: output JSON buffer number
M.md_buf_to_json_buf = function(in_buf, out_buf)
  local in_ft = vim.api.nvim_get_option_value("filetype", { buf = in_buf })
  if in_ft ~= "markdown" then
    log.debug("Buffer is not a markdown buffer")
    error("Buffer is not a markdown buffer")
  end
  local md_str = table.concat(vim.api.nvim_buf_get_lines(in_buf, 0, -1, false), "\n")
  local json_str = M.md_to_json(md_str)
  if json_str then
    out_buf = out_buf or vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "json", { buf = out_buf })
    vim.api.nvim_buf_set_lines(out_buf, 0, -1, false, vim.split(json_str, "\n"))
    return out_buf
  else
    log.debug("Generated md_str is nil")
    error("Generated md_str is nil")
  end
end

----------------------------------------------------------------------------------------------------

return M
