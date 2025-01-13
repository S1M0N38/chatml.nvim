local md_to_json = require("chatml.parse").md_to_json
local md_buf_to_json_buf = require("chatml.parse").md_buf_to_json_buf

local parser_path = os.getenv("HOME") .. "/.luarocks/lib/luarocks/rocks-5.1/tree-sitter-yaml/0.0.30-1"
vim.opt.runtimepath:append(parser_path)

local function read_file(filepath)
  local lines = vim.fn.readfile(filepath)
  return table.concat(lines, "\n")
end

describe("[#parse #md_to_json] md_to_json function tests", function()
  local data_path = "spec/data/md_to_json"
  ---@diagnostic disable-next-line
  local md_files = vim.fn.globpath(data_path, "example_*.md", false, true)
  ---@diagnostic disable-next-line
  local json_files = vim.fn.globpath(data_path, "example_*.json", false, true)

  for i = 1, #md_files do
    it(string.format("[#example] convert Markdown to JSON correctly (#%d/%d)", i, #md_files), function()
      local md_str = read_file(md_files[i])
      local expected_json = read_file(json_files[i])
      local output_json = md_to_json(md_str)
      assert(output_json ~= nil)
      assert.are.same(vim.json.decode(expected_json), vim.json.decode(output_json))
    end)
  end

  it("throw an error for invalid markdown", function()
    local invalid_md_file = data_path .. "/not_valid_markdown.md"
    local md_str = read_file(invalid_md_file)

    assert.has_error(function()
      md_to_json(md_str)
    end, "Cannot parse Markdown string")
  end)

  it("throw an error for missing model", function()
    local missing_model_file = data_path .. "/missing_model.md"
    local md_str = read_file(missing_model_file)

    assert.has_error(function()
      md_to_json(md_str)
    end, "Model key not found in front matter")
  end)

  it("throw an error for missing content", function()
    local missing_content_file = data_path .. "/missing_content.md"
    local md_str = read_file(missing_content_file)

    assert.has_error(function()
      md_to_json(md_str)
    end, "Content after front matter is empty")
  end)

  it("throw an error for missing messages", function()
    local missing_messages_file = data_path .. "/missing_messages.md"
    local md_str = read_file(missing_messages_file)

    assert.has_error(function()
      md_to_json(md_str)
    end, "No messages found")
  end)

  it("validate roles correctly", function()
    local wrong_role_file = data_path .. "/wrong_role.md"
    local md_str = read_file(wrong_role_file)

    assert.has_error(function()
      md_to_json(md_str)
    end, "Invalid role: human")
  end)
end)

describe("[#parse #md_buf_to_json_buf] md_buf_to_json_buf function tests", function()
  local md_str = read_file("spec/data/md_to_json/example_00.md")
  local expected_json = read_file("spec/data/md_to_json/example_00.json")
  local in_buf, out_buf

  before_each(function()
    in_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(in_buf, 0, -1, false, vim.split(md_str, "\n"))
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = in_buf })
  end)

  after_each(function()
    vim.api.nvim_buf_delete(in_buf, { force = true })
  end)

  it("convert markdown buffer to JSON buffer (same in/out buffer)", function()
    out_buf = md_buf_to_json_buf(in_buf, in_buf)
    assert(out_buf ~= nil)
    local output_json = table.concat(vim.api.nvim_buf_get_lines(out_buf, 0, -1, false), "\n")
    assert.are.equal(out_buf, in_buf)
    assert.are.same(vim.json.decode(expected_json), vim.json.decode(output_json))
  end)

  it("convert markdown buffer to JSON buffer (diff in/out buffer)", function()
    out_buf = md_buf_to_json_buf(in_buf)
    assert(out_buf ~= nil)
    local output_json = table.concat(vim.api.nvim_buf_get_lines(out_buf, 0, -1, false), "\n")
    assert.are_not.equal(out_buf, in_buf)
    assert.are.same(vim.json.decode(expected_json), vim.json.decode(output_json))
  end)

  it("throw an error for non-markdown input buffer", function()
    vim.api.nvim_set_option_value("filetype", "python", { buf = in_buf })
    assert.has_error(function()
      md_buf_to_json_buf(in_buf)
    end, "Buffer is not a markdown buffer")
  end)
end)
