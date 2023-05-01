local markup = require("__the418_kb__/markup/markup")

local topic_lock = require("__the418_kb__/scripts/topic-lock")
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

--- @return Topic[]
function Topic:get_children()
  --- @type Topic[]
  local children = {}

  for _, id in pairs(self.child_ids) do
    table.insert(children, global.topics[id])
  end

  return children
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

--- @return boolean
function Topic:is_locked()
  return self.lock_ ~= nil
end

--- @return TopicLock?
function Topic:get_lock()
  return self.lock_
end

--- @param player LuaPlayer
function Topic:lock(player)
  self.lock_ = topic_lock.new(player)
end

function Topic:unlock()
  self.lock_ = nil
end

-- Never set `Topic.body`, always use `Topic:set_body` instead
--- @param body string
function Topic:set_body(body)
  if self.body ~= body then
    self.body_ast = markup.parse(body)
  end
  self.body = body
end

local topic = {}

--- @param title string
--- @param body string
function topic.new(title, body)
  local id = global.next_topic_id
  global.next_topic_id = id + 1

  --- @class Topic
  --- @field package lock_ TopicLock?
  local self = {
    id = id, --- @type integer
    title = title,
    body = body,
    child_ids = {}, --- @type uint[]
    lock_ = nil,
    body_ast = markup.parse(body), --- @type AST
  }

  topic.load(self)
  global.topics[id] = self

  return self
end

--- @param self Topic
function topic.load(self)
  setmetatable(self, { __index = Topic })
  if self.lock_ then
    topic_lock.load(self.lock_)
  end
end

return topic
