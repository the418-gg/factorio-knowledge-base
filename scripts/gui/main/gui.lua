local actions = require("__the418_kb__/scripts/gui/main/actions")
local helpers = require("__the418_kb__/scripts/gui/main/helpers")
local util = require("__the418_kb__/scripts/util")

--- @class TopicsGui
local TopicsGui = {}

TopicsGui.actions = actions

function TopicsGui:open()
  self.refs.window.bring_to_front()
  self.refs.window.visible = true
  self.state.is_visible = true
  self.player.opened = self.refs.window
end

function TopicsGui:close()
  self.refs.window.visible = false
  self.state.is_visible = false

  if self.player.opened == self.refs.window then
    self.player.opened = nil
  end
end

function TopicsGui:destroy()
  local window = self.refs.window

  if window and window.valid then
    self.refs.window.destroy()
  end
  self.player_table.guis.topics = nil

  self.player.opened = nil
end

function TopicsGui:update()
  local Topic = util.get_first_valid_topic(self.state.selected_topic_id)
  self.state.selected_topic_id = Topic and Topic.id or nil

  helpers.build_topic_navigation(self)
  helpers.build_selected_topic_contents(self)

  if self.state.child then
    self.state.child:update()
  end
end

function TopicsGui:toggle()
  if self.state.is_visible then
    self:close()
  else
    self:open()
  end
end

--- @param topic_id integer
function TopicsGui:select_topic(topic_id)
  self.state.selected_topic_id = topic_id
  helpers.build_topic_navigation(self)
  helpers.build_selected_topic_contents(self)
end

function TopicsGui:dispatch(msg, e)
  if msg.action then
    local handler = self.actions[msg.action]
    if handler then
      handler(self, msg, e)
    end
  end
end

return TopicsGui
