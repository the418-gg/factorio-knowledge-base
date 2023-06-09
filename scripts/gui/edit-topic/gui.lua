local actions = require("__the418_kb__/scripts/gui/edit-topic/actions")
local helpers = require("__the418_kb__/scripts/gui/edit-topic/helpers")
local player_gui = require("__the418_kb__/scripts/player-gui")

--- @class EditTopicsGui
local EditTopicsGui = {}

EditTopicsGui.actions = actions

function EditTopicsGui:show()
  self.refs.window.bring_to_front()
  self.refs.window.visible = true
  self.state.is_visible = true
  self.player.opened = self.refs.window
end

function EditTopicsGui:hide()
  self.refs.window.visible = false
  self.state.is_visible = false
end

function EditTopicsGui:update()
  self.state.available_parents =
    helpers.make_available_parents(global.public.top_level_topic_ids, self.state.topic)
  helpers.build_parent_selector(self)
  helpers.update_confirm_button(self)

  local topic = self.state.topic or self.state.new_topic
  if not topic then
    return
  end

  if self.state.is_awaiting_parse and topic.is_body_parsed then
    self.state.is_awaiting_parse = false
    self:destroy()
  end
end

function EditTopicsGui:destroy()
  if self.state.child then
    self.state.child:destroy()
  end
  if self.state.topic then
    self.state.topic:unlock()
    player_gui.update_all_topics()
  end
  if self.state.new_topic then
    self.parent.state.selected_topic_id = self.state.new_topic.id
    player_gui.update_all_topics()
  end

  self.parent.state.child = nil
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
