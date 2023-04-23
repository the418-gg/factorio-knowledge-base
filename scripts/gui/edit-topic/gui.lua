local actions = require("__the418_kb__/scripts/gui/edit-topic/actions")

--- @class EditTopicsGui
local EditTopicsGui = {}

EditTopicsGui.actions = actions

function EditTopicsGui:destroy()
  local window = self.refs.window

  if window and window.valid then
    self.refs.window.destroy()
  end
  self.player_table.guis.edit_topic = nil

  self.player.opened = self.parent.refs.window
end

function EditTopicsGui:dispatch(msg, e)
  if msg.action then
    local handler = self.actions[msg.action]
    if handler then
      handler(self, msg, e)
    end
  end
end

return EditTopicsGui
