local player_gui = require("__the418_kb__/scripts/player-gui")
local util = require("__the418_kb__/scripts/util")

local actions = {}

--- @param Gui ConfirmDeleteTopicGui
function actions.close(Gui)
  Gui:destroy()
  Gui.parent:show()
end

--- @param Gui ConfirmDeleteTopicGui
function actions.confirm(Gui)
  -- If any child topic is currently locked, cannot delete
  local Topic = Gui.state.topic --[[@as Topic]]
  for _, ChildTopic in pairs(Topic:get_children()) do
    local Lock = ChildTopic:get_lock()
    if Lock then
      util.error_text(
        Gui.player,
        { "message.the418-kb--cannot-delete-child-is-locked", ChildTopic.title, Lock.player.name }
      )
      return
    end
  end

  Gui.state.topic:delete()

  player_gui.update_all_topics()
  Gui:destroy()
  Gui.parent:destroy()
end

return actions
