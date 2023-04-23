local gui = require("__flib__/gui")
local TopicsGui = require("__the418_kb__/scripts/gui/main/gui")
local templates = require("__the418_kb__/scripts/gui/main/templates")
local util = require("__the418_kb__/scripts/util")

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
function index.new(player, player_table)
  --- @type TopicsGuiRefs
  local refs = gui.build(player.gui.screen, templates.render())

  refs.window.force_auto_center()
  refs.titlebar_flow.drag_target = refs.window

  local SelectedTopic = util.get_first_valid_topic()
  local selected_topic_id = (SelectedTopic and SelectedTopic.id or nil)

  --- @class TopicsGui
  local self = {
    player = player,
    player_table = player_table,
    refs = refs,
    --- @class TopicsGuiState
    state = {
      is_visible = false,
      prevent_close = false,
      selected_topic_id = selected_topic_id,
    },
  }

  setmetatable(self, { __index = TopicsGui })

  self:select_topic(self.state.selected_topic_id)
  player_table.guis.topics = self
end

--- @param Gui TopicsGui
function index.load(Gui)
  setmetatable(Gui, { __index = TopicsGui })
end

return index
