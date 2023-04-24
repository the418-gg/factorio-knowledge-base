local gui = require("__flib__/gui")
local templates = require("__the418_kb__/scripts/gui/edit-topic/templates")

local helpers = {}

--- @param pool uint[]
--- @param Topic Topic?
--- @return Topic[]
function helpers.make_available_parents(pool, Topic)
  local result = {}

  for _, id in ipairs(pool) do
    if not Topic or id ~= Topic.id then
      local t = global.topics[id]
      table.insert(result, t)
      for _, v in ipairs(helpers.make_available_parents(t.child_ids, Topic)) do
        table.insert(result, v)
      end
    end
  end

  return result
end

--- @param Gui EditTopicsGui
function helpers.build_parent_selector(Gui)
  Gui.refs.parent_dropdown_container.clear()

  Gui.refs.parent_dropdown = templates.render_parent_selector(
    Gui.state.topic,
    Gui.state.available_parents,
    Gui.parent.state.selected_topic_id
  )
  gui.add(Gui.refs.parent_dropdown_container, Gui.refs.parent_dropdown)
end

return helpers
