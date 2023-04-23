local topics_gui_index = require("__the418_kb__/scripts/gui/main/index")

local player_data = {}

--- @param player LuaPlayer
function player_data.init(player)
  --- @class PlayerTable
  global.players[player.index] = {
    --- @type PlayerGuis
    guis = {},
  }
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
function player_data.refresh(player, player_table)
  local TopicsGui = player_table.guis.topics
  if TopicsGui then
    TopicsGui:destroy()
  end
  topics_gui_index.new(player, player_table)

  local EditTopicsGui = player_table.guis.edit_topic
  if EditTopicsGui then
    EditTopicsGui:destroy()
  end
end

--- @class PlayerGuis
--- @field topics TopicsGui?
--- @field edit_topic EditTopicsGui?

return player_data