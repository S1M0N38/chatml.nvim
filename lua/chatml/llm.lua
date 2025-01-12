local log = require("chatml.log")
local parse = require("chatml.parse")
local ai = require("ai")

---@class ChatMLLLM
local M = {}

M.client = ai.Client:new()

--[[
The function `last` is from olimorris/codecompanion.nvim repo:
  https://github.com/olimorris/codecompanion.nvim/blob/f8db284e1197a8cc4235afa30dcc3e8d4f3f45a5/lua/codecompanion/strategies/chat.lua#L987

Check out NOTICE.md for more information about the original code.
--]]

---Get the last line, column and line count in the chat buffer
---@param buf integer: The buffer number
---@return integer: number of the last line
---@return integer: number of columns in the last line
local function last(buf)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local last_line = line_count - 1
  if last_line < 0 then
    return 0, 0
  end
  local last_line_content = vim.api.nvim_buf_get_lines(buf, -2, -1, false)
  if not last_line_content or #last_line_content == 0 then
    return last_line, 0
  end
  local last_column = #last_line_content[1]
  return last_line, last_column
end

local function on_chat_completion(out_buf)
  local last_role = ""
  return function(chat_completion_obj)
    -- role
    local role = chat_completion_obj.choices[1].message.role
    if role ~= nil and role ~= "" and last_role ~= role then
      local role_lines = { "", "# " .. role, "" }
      vim.api.nvim_buf_set_lines(out_buf, -1, -1, true, role_lines)
      last_role = role
    end

    -- content
    local content = chat_completion_obj.choices[1].message.content
    local content_lines = vim.split(content, "\n", { plain = true, trimempty = false })
    vim.api.nvim_buf_set_lines(out_buf, -1, -1, true, content_lines)

    -- separator
    vim.api.nvim_buf_set_lines(out_buf, -1, -1, true, { "", "---" })
  end
end

local function on_chat_completion_chunk(out_buf)
  local last_role = ""
  return function(chat_completion_chunk_obj)
    -- role
    local role = chat_completion_chunk_obj.choices[1].delta.role
    if role ~= nil and role ~= "" and last_role ~= role then
      local role_lines = { "", "# " .. role, "", "" }
      vim.api.nvim_buf_set_lines(out_buf, -1, -1, true, role_lines)
      last_role = role
    end
    -- content
    local content = chat_completion_chunk_obj.choices[1].delta.content
    local finish_reason = chat_completion_chunk_obj.choices[1].finish_reason
    if finish_reason == nil then
      local lines = vim.split(content, "\n", { plain = true, trimempty = false })
      local last_line, last_column = last(out_buf)
      vim.api.nvim_buf_set_text(out_buf, last_line, last_column, last_line, last_column, lines)
    elseif finish_reason == "stop" then
      -- separator
      vim.api.nvim_buf_set_lines(out_buf, -1, -1, true, { "", "---" })
      vim.notify("Done.", vim.log.levels.INFO)
    else
      vim.notify("An error occured during text genereation.", vim.log.levels.ERROR)
    end
  end
end

---Send chat completion request to LLM and add response to output buffer
---@param in_buf number: input markdown buffer number
---@param out_buf number?: output markdown buffer number
M.chat_completion = function(in_buf, out_buf)
  local in_ft = vim.api.nvim_get_option_value("filetype", { buf = in_buf })
  if in_ft ~= "markdown" then
    log.debug("Input buffer is not a markdown buffer")
    error("Input buffer is not a markdown buffer")
  end
  if out_buf then
    local out_ft = vim.api.nvim_get_option_value("filetype", { buf = out_buf })
    if out_ft ~= "markdown" then
      log.debug("Output buffer is not a markdown buffer")
      error("Output buffer is not a markdown buffer")
    end
  end

  local md_str = table.concat(vim.api.nvim_buf_get_lines(in_buf, 0, -1, false), "\n"):gsub("%s+$", "")
  local json_str = parse.md_to_json(md_str)
  local ok, request = pcall(vim.json.decode, json_str, { luanil = { object = true, array = true } })

  if not ok or type(request) ~= "table" then
    log.error("Cannot parse JSON string into request", request)
    error("Cannot parse JSON string into request")
  end

  out_buf = out_buf or in_buf
  vim.api.nvim_buf_set_lines(out_buf, 0, -1, false, vim.split(md_str, "\n"))

  log.debug("request: ", request)
  vim.notify(string.format("Sending request to %s...(%d messages)", M.client.base_url, #request.messages))

  M.client:chat_completion_create(request, on_chat_completion(out_buf), on_chat_completion_chunk(out_buf))
end

return M
