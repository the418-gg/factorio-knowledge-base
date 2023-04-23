local gui = require("__flib__/gui")
local templates = require("__the418_kb__/scripts/gui/main/templates")

local helpers = {}

--- @param into LuaGuiElement
--- @param level uint
--- @param id integer
--- @param selected_id integer?
local function build_topic_navigation_rec(into, level, id, selected_id)
  local Topic = global.topics[id]
  gui.add(into, templates.topic_button(id, Topic.title, level, selected_id == id))

  for _, child_id in pairs(Topic.child_ids) do
    build_topic_navigation_rec(into, level + 1, child_id, selected_id)
  end
end

--- @param Gui TopicsGui
function helpers.build_topic_navigation(Gui)
  Gui.refs.topic_navigation.clear()
  for _, id in pairs(global.public.top_level_topic_ids) do
    build_topic_navigation_rec(Gui.refs.topic_navigation, 1, id, Gui.state.selected_topic_id)
  end
end

--- @param Gui TopicsGui
function helpers.build_selected_topic_contents(Gui)
  Gui.refs.current_topic_contents.clear()
  if Gui.state.selected_topic_id then
    local Topic = global.topics[Gui.state.selected_topic_id]
    gui.add(Gui.refs.current_topic_contents, templates.topic_contents(Topic))
  end
end

return helpers
