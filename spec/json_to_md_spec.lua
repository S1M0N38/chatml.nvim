local json_to_md = require("chatml.parse").json_to_md
local json_buf_to_md_buf = require("chatml.parse").json_buf_to_md_buf

local function read_file(filepath)
  local lines = vim.fn.readfile(filepath)
  return table.concat(lines, "\n")
end

describe("[#parse #json_to_md] json_to_md function tests", function()
  local data_path = "spec/data/json_to_md"
  local json_files = vim.fn.globpath(data_path, "example_*.json", false, true)
  local md_files = vim.fn.globpath(data_path, "example_*.md", false, true)

  for i = 1, #json_files do
    it(string.format("[#example] convert JSON to Markdown correctly (#%d/%d)", i, #json_files), function()
      local json_str = read_file(json_files[i])
      local expected_md = read_file(md_files[i])
      local output_md = json_to_md(json_str)
      assert.are.equal(expected_md, output_md)
    end)
  end

  it("throw an error for invalid JSON", function()
    local invalid_json_file = data_path .. "/not_valid_json.json"
    local json_str = read_file(invalid_json_file)

    assert.has_error(function()
      json_to_md(json_str)
    end, "Invalid JSON string")
  end)

  it("throw an error for missing 'messages' key", function()
    local missing_messages_file = data_path .. "/missing_messages.json"
    local json_str = read_file(missing_messages_file)

    assert.has_error(function()
      json_to_md(json_str)
    end, "Messages key not found in JSON")
  end)

  it("throw a validation error for missing 'model' key", function()
    local missing_model_file = data_path .. "/missing_model.json"
    local json_str = read_file(missing_model_file)
    assert.has_error(function()
      json_to_md(json_str)
    end, "Model key not found in JSON")
  end)

  it("validate roles correctly", function()
    local wrong_role_file = data_path .. "/wrong_role.json"
    local json_str = read_file(wrong_role_file)

    assert.has_error(function()
      json_to_md(json_str)
    end, "Invalid role: human")
  end)
end)

describe("[#parse #json_buf_to_md_buf] json_buf_to_md_buf function tests", function()
  local json_str = read_file("spec/data/json_to_md/example_00.json")
  local expected_md = read_file("spec/data/json_to_md/example_00.md")
  local in_buf, out_buf

  before_each(function()
    in_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(in_buf, 0, -1, false, vim.split(json_str, "\n"))
    vim.api.nvim_set_option_value("filetype", "json", { buf = in_buf })
  end)

  after_each(function()
    vim.api.nvim_buf_delete(in_buf, { force = true })
  end)

  it("convert json buffer to markdown buffer (same in/out buffer)", function()
    out_buf = json_buf_to_md_buf(in_buf, in_buf)
    local output_md = table.concat(vim.api.nvim_buf_get_lines(out_buf, 0, -1, false), "\n")
    assert.are.equal(out_buf, in_buf)
    assert.are.equal(expected_md, output_md)
  end)

  it("convert json buffer to markdown buffer (diff in/out buffer)", function()
    out_buf = json_buf_to_md_buf(in_buf)
    local output_md = table.concat(vim.api.nvim_buf_get_lines(out_buf, 0, -1, false), "\n")
    assert.are_not.equal(out_buf, in_buf)
    assert.are.equal(expected_md, output_md)
  end)

  it("throw an error for non-JSON input buffer", function()
    vim.api.nvim_set_option_value("filetype", "python", { buf = in_buf })
    assert.has_error(function()
      json_buf_to_md_buf(in_buf)
    end, "Buffer is not a JSON buffer")
  end)
end)
