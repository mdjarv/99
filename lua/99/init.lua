local Logger = require("logger.logger")
local editor = require("editor")
local Point = require("geo").Point

--- @class LoggerOptions
--- @field level number?
--- @field path string?

--- @class _99Options
--- @field logger LoggerOptions?

--- @class _99
local _99 = {}
_99.__index = _99

--- @param opts _99Options
--- @return _99
function _99:new(opts)
	return setmetatable({}, self)
end

function _99:fill_in_function()
    print("fill_in_function")
    local ts = editor.treesitter
    local cursor = Point:from_cursor()
    local scopes = ts.scopes(cursor)
    print(vim.inspect(scopes))
end

--- @param opts _99Options?
local function init(opts)
    opts = opts or {}
	local logger = opts.logger
	if logger then
		if logger.level then
			Logger:set_level(logger.level)
		end
		if logger.path then
			Logger:file_sink(logger.path)
		end
	end

	local nn = _99:new(opts)

    return nn
end

local nn = init()
nn:fill_in_function()

return init
