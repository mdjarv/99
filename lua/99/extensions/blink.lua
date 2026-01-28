local Agents = require("99.extensions.agents")
local Helpers = require("99.extensions.agents.helpers")

--- @class _99.Extensions.BlinkItem
--- @field rule _99.Agents.Rule
--- @field docs string

--- @param _99 _99.State
--- @return _99.Extensions.BlinkItem[]
local function rules(_99)
  local agent_rules = Agents.rules_to_items(_99.rules)
  local out = {}
  for _, rule in ipairs(agent_rules) do
    table.insert(out, {
      rule = rule,
      docs = Helpers.head(rule.path),
    })
  end
  return out
end

--- @class BlinkSource
--- @field _99 _99.State
--- @field items _99.Extensions.BlinkItem[]
local BlinkSource = {}
BlinkSource.__index = BlinkSource

function BlinkSource.new()
  local _99 = require("99").__get_state()
  return setmetatable({
    _99 = _99,
    items = rules(_99),
  }, BlinkSource)
end

function BlinkSource:enabled()
  return true
end

function BlinkSource:get_trigger_characters()
  return { "@" }
end

function BlinkSource:get_completions(ctx, callback)
  local col = ctx.cursor[2]
  local before = ctx.line:sub(1, col)

  if #before > 1 and before:sub(#before - 1) ~= " @" then
    callback({ items = {}, is_incomplete_forward = false })
    return
  end

  local items = {}
  for _, item in ipairs(self.items) do
    table.insert(items, {
      label = item.rule.name,
      insertText = item.rule.path,
      filterText = item.rule.name,
      kind = 17,
      documentation = { kind = "markdown", value = item.docs },
      detail = item.rule.path,
    })
  end

  callback({
    items = items,
    is_incomplete_forward = false,
    is_incomplete_backward = false,
  })
end

function BlinkSource:resolve(item, callback)
  callback(item)
end

function BlinkSource:execute(_, item, callback)
  callback(item)
end

--- @type BlinkSource | nil
local source = nil

--- @param _99 _99.State
local function init(_99)
  source = BlinkSource.new()
  source.items = rules(_99)
end

--- @param _ _99.State
local function init_for_buffer(_)
  -- blink handles this via user config, no per-buffer setup needed
end

--- @param _99 _99.State
local function refresh_state(_99)
  if source then
    source.items = rules(_99)
  end
end

--- @type _99.Extensions.Source
local source_wrapper = {
  new = BlinkSource.new,
  init = init,
  init_for_buffer = init_for_buffer,
  refresh_state = refresh_state,
}
return source_wrapper
