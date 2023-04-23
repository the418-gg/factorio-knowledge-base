local topic = require("__the418_kb__/scripts/topic")
local util = require("__the418_kb__/scripts/util")

local actions = {}

--- @param Gui EditTopicsGui
function actions.close(Gui)
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

  Gui.parent:update()

  -- HACK pressing "E" to confirm will close the GUI that's currently open
  if msg.from == "custom-input" then
    Gui.player.play_sound({ path = "utility/confirm" })
  else
    Gui:destroy()
  end
end

--- @param Gui EditTopicsGui
function actions.delete(Gui)
  Gui.state.topic:delete()

  Gui.parent:update()
  Gui:destroy()
end

return actions
