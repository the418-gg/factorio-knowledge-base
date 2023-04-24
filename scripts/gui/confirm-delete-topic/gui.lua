local actions = require("__the418_kb__/scripts/gui/confirm-delete-topic/actions")

--- @class ConfirmDeleteTopicGui
local ConfirmDeleteTopicGui = {}

ConfirmDeleteTopicGui.actions = actions

function ConfirmDeleteTopicGui:destroy()
  local window = self.refs.window

  if window and window.valid then
    self.refs.window.destroy()
  end
  self.player_table.guis.confirm_delete_topic = nil

  self.player.opened = self.parent.refs.window
end

function ConfirmDeleteTopicGui:dispatch(msg, e)
  if msg.action then
    local handler = self.actions[msg.action]
    if handler then
      handler(self, msg, e)
    end
  end
end

return ConfirmDeleteTopicGui
