---@diagnostic disable: lowercase-global
local _MODREV, _SPECREV = "scm", "-1"
rockspec_format = "3.0"
version = _MODREV .. _SPECREV

local user = "S1M0N38"
package = "chatml.nvim"

description = {
	summary = "OpenAI chat completion request (JSON) ⇋ markdown & sent requests",
	labels = { "neovim" },
	homepage = "https://github.com/" .. user .. "/" .. package,
	license = "MIT",
}

dependencies = {
	"ai.nvim >= 1.4.2-1",
}

test_dependencies = {
	"nlua",
	"nvim-treesitter",
}

source = {
	url = "git://github.com/" .. user .. "/" .. package,
}

build = {
	type = "builtin",
}
