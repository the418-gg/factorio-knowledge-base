local gui = require("__flib__/gui")
local templates = require("__the418_kb__/scripts/gui/main/templates")
local topic_body = require("__the418_kb__/scripts/gui/main/topic-body")
local test = require("__the418_kb__/scripts/markup/test")

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
    local ast = test.parse(Topic.body)
    game.print("AST" .. serpent.block(ast))
    local contents = topic_body.from_ast(ast)
    gui.add(Gui.refs.current_topic_contents, templates.topic_contents(Topic, contents))
  else
    gui.add(Gui.refs.current_topic_contents, templates.no_topic_area())
  end
end

return helpers
