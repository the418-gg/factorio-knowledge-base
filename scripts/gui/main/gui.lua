local gui = require("__flib__/gui")
local gui_stack = require("__the418_kb__/scripts/gui/stack")
local templates = require("__the418_kb__/scripts/gui/main/templates")

local main_gui = {}

--- @param into LuaGuiElement
--- @param level number
--- @param id number
--- @param selected_id number
local function render_topic_navigation(into, level, id, selected_id)
  local topic = global.topics[id]
  gui.add(into, templates.topic_button(id, topic.title, level, selected_id == id))

  for _, child_id in pairs(topic.child_ids) do
    render_topic_navigation(into, level + 1, child_id, selected_id)
  end
end

--- @param player LuaPlayer
--- @param guis table
function main_gui.open(player, guis)
  local global_player = global.players[player.index]

  --- @type MainGuiRefs
  local refs = gui.build(player.gui.screen, templates.render())

  for _, id in pairs(global.public.top_level_topic_ids) do
    render_topic_navigation(refs.topic_navigation, 1, id,
      global_player.selected_topic_id)
  end
  local current_topic = global.topics[global_player.selected_topic_id]
  if current_topic then
    gui.add(refs.current_topic_contents, templates.topic_contents(current_topic))
  end

  refs.window.force_auto_center()
  refs.titlebar_flow.drag_target = refs.window
  gui_stack.push(global_player.gui_stack, {
    refs = refs,
    handle_event = function(msg)
      if msg.gui == "topics" and msg.action == "select" then
        global_player.selected_topic_id = msg.topic_id
        main_gui.close(player)
        main_gui.open(player, guis)
      elseif msg.gui == "topics" and msg.action == "close" then
        local current_gui = gui_stack.current(global_player.gui_stack)
        if current_gui and current_gui.refs.window == refs.window then
          gui_stack.pop(global_player.gui_stack)
          refs.window.destroy()
        end
      elseif msg.gui == "topics" and msg.action == "add-topic" then
        guis.edit_topic.open(player, nil, guis)
      elseif msg.gui == "topics" and msg.action == "edit-topic" then
        local topic = global.topics[msg.topic_id]
        guis.edit_topic.open(player, topic, guis)
      end
    end,
  })
  player.opened = refs.window
end

--- @param player LuaPlayer
function main_gui.close(player)
  local player_gui = global.players[player.index].gui_stack
  local current_gui = gui_stack.current(player_gui)

  while (current_gui) do
    current_gui.refs.window.destroy()
    gui_stack.pop(player_gui)
    current_gui = gui_stack.current(player_gui)
  end
  player.opened = nil
end

--- @param player LuaPlayer
--- @param guis table
function main_gui.toggle(player, guis)
  local player_gui = global.players[player.index].gui_stack
  local current_gui = gui_stack.current(player_gui)

  if current_gui then
    main_gui.close(player)
  else
    main_gui.open(player, guis)
  end
end

return main_gui
