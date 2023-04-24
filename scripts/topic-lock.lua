--- @class TopicLock
local TopicLock = {}

local topic_lock = {}

--- @param player LuaPlayer
function topic_lock.new(player)
  --- @class TopicLock
  local self = {
    player = player,
    tick = game.tick,
  }

  topic_lock.load(self)

  return self
end

--- @param self TopicLock
function topic_lock.load(self)
  setmetatable(self, { __index = TopicLock })
end

return topic_lock
