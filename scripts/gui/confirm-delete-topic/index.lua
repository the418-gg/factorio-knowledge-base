local gui = require("__flib__/gui")
local ConfirmDeleteTopicGui = require("__the418_kb__/scripts/gui/confirm-delete-topic/gui")
local templates = require("__the418_kb__/scripts/gui/confirm-delete-topic/templates")

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
--- @param Topic Topic
--- @param ParentGui EditTopicsGui
function index.new(player, player_table, Topic, ParentGui)
  --- @type ConfirmDeleteTopicGuiRefs
  local refs = gui.build(player.gui.screen, templates.render(Topic))

  refs.window.force_auto_center()

  --- @class ConfirmDeleteTopicGui
  local self = {
    player = player,
    player_table = player_table,
    refs = refs,
    parent = ParentGui,
    --- @class ConfirmDeleteTopicGuiState
    state = {
      topic = Topic,
    },
  }

  setmetatable(self, { __index = ConfirmDeleteTopicGui })

  player_table.guis.confirm_delete_topic = self
  player.opened = refs.window
end

--- @param Gui ConfirmDeleteTopicGui
function index.load(Gui)
  setmetatable(Gui, { __index = ConfirmDeleteTopicGui })
end

return index
