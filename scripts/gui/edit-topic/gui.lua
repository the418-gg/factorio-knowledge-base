local gui = require("__flib__/gui")
local gui_stack = require("__the418_kb__/scripts/gui/stack")
local templates = require(
  "__the418_kb__/scripts/gui/edit-topic/templates")
local util = require("__the418_kb__/scripts/util")

local edit_topic_gui = {}

--- @param pool number[]
--- @param topic Topic?
--- @return Topic[]
local function make_available_parents(pool, topic)
  local result = {}

  for _, id in ipairs(pool) do
    if not topic or id ~= topic.id then
      local t = global.topics[id]
      table.insert(result, t)
      for _, v in ipairs(make_available_parents(t.child_ids, topic)) do
        table.insert(result, v)
      end
    end
  end

  return result
end

--- @param player LuaPlayer
--- @param topic Topic?
--- @param guis table
function edit_topic_gui.open(player, topic, guis)
  local global_player = global.players[player.index]
  local available_parents = make_available_parents(
    global.public.top_level_topic_ids, topic)

  --- @type EditTopicGuiRefs
  local refs = gui.build(player.gui.screen,
    templates.render(topic, available_parents))
  refs.window.force_auto_center()
  refs.titlebar_flow.drag_target = refs.window
  refs.footer_flow.drag_target = refs.window
  refs.title_textfield.select_all()
  refs.title_textfield.focus()

  local selected_parent_index_cache = refs.parent_dropdown.selected_index

  gui_stack.push(global_player.gui_stack, {
    refs = refs,
    handle_event = function(msg)
      if msg.gui == "edit_topic" then
        if msg.action == "close" then
          refs.window.destroy()
          gui_stack.pop(global_player.gui_stack)
          local current_gui = gui_stack.current(global_player.gui_stack)
          if current_gui then
            player.opened = current_gui.refs.window
          end
        elseif msg.action == "confirm" then
          if #refs.title_textfield.text == 0 then
            player.create_local_flying_text({
              create_at_cursor = true,
              text = { "message.the418-kb--topic-must-have-title" },
            })
            player.play_sound({ path = "utility/cannot_build" })
            return
          end

          if topic then
            topic.title = refs.title_textfield.text
            topic.body = refs.body_textfield.text

            local parent_selection_index = refs.parent_dropdown.selected_index
            local current_parent
            for _, t in ipairs(global.topics) do
              if util.has_value(t.child_ids, topic.id) then
                current_parent = t
              end
            end

            if parent_selection_index ~= selected_parent_index_cache or (current_parent and parent_selection_index == 1) then
              if current_parent then
                util.remove_value(current_parent.child_ids, topic.id)
              else
                util.remove_value(global.public.top_level_topic_ids, topic.id)
              end

              if parent_selection_index == 1 then
                table.insert(global.public.top_level_topic_ids, topic.id)
              else
                local parent = available_parents[parent_selection_index - 1]
                table.insert(parent.child_ids, topic.id)
              end
            end
          else
            --- @type Topic
            local created_topic = {
              id = global.next_topic_id,
              title = refs.title_textfield.text,
              body = refs.body_textfield.text,
              child_ids = {},
            }
            global.next_topic_id = global.next_topic_id + 1

            global.topics[created_topic.id] = created_topic
            local parent_selection_index = refs.parent_dropdown.selected_index
            if parent_selection_index == 1 then
              table.insert(global.public.top_level_topic_ids, created_topic.id)
            else
              local parent = available_parents[parent_selection_index - 1]
              table.insert(parent.child_ids, created_topic.id)
            end
          end

          guis.main.close(player)
          guis.main.open(player, guis)

          -- HACK
          if msg.from == "custom-input" then
            guis.edit_topic.open(player, nil, guis)
          end
        elseif msg.action == "delete" and topic then
          util.remove_value(global.topics, topic)

          for _, p in ipairs(global.players) do
            if p.selected_topic_id == topic.id then
              p.selected_topic_id = nil
            end
          end

          local current_parent
          for _, t in ipairs(global.topics) do
            if util.has_value(t.child_ids, topic.id) then
              current_parent = t
            end
          end

          if current_parent then
            util.remove_value(current_parent.child_ids, topic.id)
          else
            util.remove_value(global.public.top_level_topic_ids, topic.id)
          end

          guis.main.close(player)
          guis.main.open(player, guis)
        end
      end
    end,
  })
  player.opened = refs.window
end

return edit_topic_gui
