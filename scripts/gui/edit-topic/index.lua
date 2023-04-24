local gui = require("__flib__/gui")
local EditTopicsGui = require("__the418_kb__/scripts/gui/edit-topic/gui")
local templates = require("__the418_kb__/scripts/gui/edit-topic/templates")
local player_gui = require("__the418_kb__/scripts/player-gui")

local index = {}

--- @param pool uint[]
--- @param Topic Topic?
--- @return Topic[]
local function make_available_parents(pool, Topic)
  local result = {}

  for _, id in ipairs(pool) do
    if not Topic or id ~= Topic.id then
      local t = global.topics[id]
      table.insert(result, t)
      for _, v in ipairs(make_available_parents(t.child_ids, Topic)) do
        table.insert(result, v)
      end
    end
  end

  return result
end

--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param Topic Topic?
--- @param ParentGui TopicsGui
function index.new(player, player_table, Topic, ParentGui)
  local available_parents = make_available_parents(global.public.top_level_topic_ids, Topic)

  --- @type EditTopicGuiRefs
  local refs = gui.build(player.gui.screen, templates.render(Topic, available_parents))

  refs.window.force_auto_center()
  refs.titlebar_flow.drag_target = refs.window
  refs.footer_flow.drag_target = refs.window

  --- @class EditTopicsGui
  local self = {
    player = player,
    player_table = player_table,
    refs = refs,
    parent = ParentGui,
    --- @class EditTopicsGuiState
    state = {
      available_parents = available_parents,
      selected_parent_index = refs.parent_dropdown.selected_index,
      topic = Topic and Topic or nil,
      is_visible = true,
      prevent_close = false,
    },
  }

  setmetatable(self, { __index = EditTopicsGui })

  if Topic then
    -- Lock this topic for editing
    Topic:lock(player)
    player_gui.update_all_topics()
  end

  player_table.guis.edit_topic = self

  player.opened = refs.window
  refs.title_textfield.select_all()
  refs.title_textfield.focus()
end

--- @param Gui EditTopicsGui
function index.load(Gui)
  setmetatable(Gui, { __index = EditTopicsGui })
end

return index
