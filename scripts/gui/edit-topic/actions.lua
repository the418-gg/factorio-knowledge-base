local topic = require("__the418_kb__/scripts/topic")
local util = require("__the418_kb__/scripts/util")
local player_gui = require("__the418_kb__/scripts/player-gui")
local confirm_delete_topic_index = require("__the418_kb__/scripts/gui/confirm-delete-topic/index")

local actions = {}

--- @param Gui EditTopicsGui
function actions.close(Gui)
  if Gui.state.prevent_close then
    Gui.state.prevent_close = false
    return
  end

  local Topic = Gui.state.topic
  if Topic then
    Topic:unlock()
  end

  player_gui.update_all_topics()
  Gui:destroy()
end

--- @param Gui EditTopicsGui
--- @param msg {from: "custom-input" | nil}
function actions.confirm(Gui, msg)
  if #Gui.refs.title_textfield.text == 0 then
    util.error_text(Gui.player, { "message.the418-kb--topic-must-have-title" })
    return
  end

  local Topic = Gui.state.topic
  if Topic then
    Topic.title = Gui.refs.title_textfield.text
    Topic.body = Gui.refs.body_textfield.text

    local parent_selection_index = Gui.refs.parent_dropdown.selected_index
    local Parent = Topic:get_current_parent()

    if
      parent_selection_index ~= Gui.state.selected_parent_index
      or (Parent and parent_selection_index == 1)
    then
      if Parent then
        Parent:remove_child(Topic.id)
      else
        util.remove_value(global.public.top_level_topic_ids, Topic.id)
      end

      if parent_selection_index == 1 then
        table.insert(global.public.top_level_topic_ids, Topic.id)
      else
        local NewParent = Gui.state.available_parents[parent_selection_index - 1]
        NewParent:add_child(Topic.id)
      end
    end

    Topic:unlock()
  else
    local NewTopic = topic.new(Gui.refs.title_textfield.text, Gui.refs.body_textfield.text)

    global.topics[NewTopic.id] = NewTopic
    local parent_selection_index = Gui.refs.parent_dropdown.selected_index
    if parent_selection_index == 1 then
      table.insert(global.public.top_level_topic_ids, NewTopic.id)
    else
      local Parent = Gui.state.available_parents[parent_selection_index - 1]
      Parent:add_child(NewTopic.id)
    end
  end

  player_gui.update_all_topics()

  -- HACK pressing "E" to confirm will close the GUI that's currently open
  if msg.from == "custom-input" then
    Gui.player.play_sound({ path = "utility/confirm" })
  else
    Gui:destroy()
  end
end

--- @param Gui EditTopicsGui
function actions.delete(Gui)
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

  Gui:hide()
  Gui.state.prevent_close = true
  confirm_delete_topic_index.new(Gui.player, Gui.player_table, Topic, Gui)
end

return actions
