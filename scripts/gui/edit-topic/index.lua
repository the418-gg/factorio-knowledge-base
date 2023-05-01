local gui = require("__flib__/gui")
local EditTopicsGui = require("__the418_kb__/scripts/gui/edit-topic/gui")
local helpers = require("__the418_kb__/scripts/gui/edit-topic/helpers")
local templates = require("__the418_kb__/scripts/gui/edit-topic/templates")
local player_gui = require("__the418_kb__/scripts/player-gui")

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param Topic Topic?
--- @param ParentGui TopicsGui
--- @return EditTopicsGui
function index.new(player, player_table, Topic, ParentGui)
  local available_parents = helpers.make_available_parents(global.public.top_level_topic_ids, Topic)
  local gui_data = player_table.guis.topics
  local currently_selected_topic_id = gui_data and gui_data.state.selected_topic_id or nil

  --- @type EditTopicGuiRefs
  local refs = gui.build(
    player.gui.screen,
    templates.render(Topic, available_parents, currently_selected_topic_id)
  )

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
      new_topic = nil,
      is_awaiting_parse = false,
      was_just_shortcut_confirmed = false,
      is_visible = false,
      child = nil, --- @type ConfirmDeleteTopicGui?
    },
  }

  setmetatable(self, { __index = EditTopicsGui })

  if Topic then
    -- Lock this topic for editing
    Topic:lock(player)
    player_gui.update_all_topics()
  end

  player_table.guis.edit_topic = self

  refs.title_textfield.select_all()
  refs.title_textfield.focus()
  return self
end

--- @param Gui EditTopicsGui
function index.load(Gui)
  setmetatable(Gui, { __index = EditTopicsGui })
end

return index
