local player_gui = require("__the418_kb__/scripts/player-gui")
local edit_topic_gui_index = require("__the418_kb__/scripts/gui/edit-topic/index")
local util = require("__the418_kb__/scripts/util")

local actions = {}

--- @param Gui TopicsGui
function actions.close(Gui)
  if Gui.state.prevent_close then
    Gui.state.prevent_close = false
    return
  end
  Gui:close()
end

--- @param Gui TopicsGui
function actions.toggle(Gui)
  Gui:toggle()
end

--- @param Gui TopicsGui
--- @param msg {topic_id: uint}
function actions.select(Gui, msg)
  Gui:select_topic(msg.topic_id)
end

--- @param Gui TopicsGui
function actions.add_topic(Gui)
  if not player_gui.get_gui(Gui.player.index, "edit_topic") then
    Gui.state.prevent_close = true
    edit_topic_gui_index.new(Gui.player, Gui.player_table, nil, Gui)
  end
end

--- @param Gui TopicsGui
--- @param msg {topic_id: uint}
function actions.edit_topic(Gui, msg)
  local Topic = global.topics[msg.topic_id]
  local Lock = Topic:get_lock()
  if Lock then
    util.error_text(Gui.player, { "message.the418-kb--topic-is-locked", Lock.player.name })
    return
  end

  if not player_gui.get_gui(Gui.player.index, "edit_topic") then
    Gui.state.prevent_close = true
    edit_topic_gui_index.new(Gui.player, Gui.player_table, Topic, Gui)
  end
end

return actions
