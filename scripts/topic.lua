local util = require("__the418_kb__/scripts/util")

--- @class Topic
local Topic = {}

--- @return Topic?
function Topic:get_current_parent()
  for _, t in pairs(global.topics) do
    if util.has_value(t.child_ids, self.id) then
      return t
    end
  end
end

--- @param id integer
function Topic:remove_child(id)
  util.remove_value(self.child_ids, id)
end

--- @param id integer
function Topic:add_child(id)
  table.insert(self.child_ids, id)
end

function Topic:delete()
  for _, id in pairs(self.child_ids) do
    global.topics[id] = nil
  end

  local Parent = self:get_current_parent()
  if Parent then
    Parent:remove_child(self.id)
  else
    util.remove_value(global.public.top_level_topic_ids, self.id)
  end

  global.topics[self.id] = nil
end

local topic = {}

--- @param title string
--- @param body string
function topic.new(title, body)
  local id = global.next_topic_id
  global.next_topic_id = id + 1

  --- @class Topic
  local self = {
    id = id, --- @type integer
    title = title,
    body = body,
    child_ids = {}, --- @type uint[]
  }

  topic.load(self)
  global.topics[id] = self

  return self
end

--- @param self Topic
function topic.load(self)
  setmetatable(self, { __index = Topic })
end

return topic
