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

--- @param Gui EditTopicsGui
function helpers.update_confirm_button(Gui)
  local topic = Gui.state.topic or Gui.state.new_topic
  if not topic then
    return
  end

  local confirm_btn = Gui.refs.confirm_button
  local delete_btn = Gui.refs.delete_button
  local back_btn = Gui.refs.cancel_button

  if topic.is_body_parsed then
    confirm_btn.caption = { "gui.confirm" }
    confirm_btn.enabled = true
    if delete_btn then
      delete_btn.enabled = true
    end
    back_btn.enabled = true
  else
    confirm_btn.caption = { "gui.the418-kb--saving-topic" }
    confirm_btn.enabled = false
    if delete_btn then
      delete_btn.enabled = false
    end
    back_btn.enabled = false
  end
end

return helpers
