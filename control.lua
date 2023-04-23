local gui = require("__flib__/gui")

local migrations = require("__the418_kb__/scripts/migrations")
local player_data = require("__the418_kb__/scripts/player-data")
local player_gui = require("__the418_kb__/scripts/player-gui")
local topic = require("__the418_kb__/scripts/topic")
local topics_gui_index = require("__the418_kb__/scripts/gui/main/index")
local edit_topic_gui_index = require("__the418_kb__/scripts/gui/edit-topic/index")

script.on_init(function()
  global.public = {
    top_level_topic_ids = { 1 },
  }
  --- @type table<uint, PlayerTable>
  global.players = {}

  global.next_topic_id = 1
  --- @type table<uint, Topic>
  global.topics = {}
  global.topics[1] = topic.new("Welcome", "Hello world")

  for _, player in pairs(game.players) do
    player_data.init(player)
  end

  migrations.generic()
end)

script.on_load(function()
  for _, Topic in pairs(global.topics) do
    topic.load(Topic)
  end

  for _, player_table in pairs(global.players) do
    topics_gui_index.load(player_table.guis.topics)
    if player_table.guis.edit_topic then
      edit_topic_gui_index.load(player_table.guis.edit_topic)
    end
  end
end)

script.on_configuration_changed(function(e)
  if e.migration_applied then
    migrations.generic()
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  player_data.init(player)
end)

script.on_event("the418-kb--toggle-interface", function(event)
  local TopicsGui = player_gui.get_gui(event.player_index, "topics")
  if TopicsGui then
    TopicsGui:toggle()
  else
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local player_table = global.players[event.player_index]
    player_data.refresh(player, player_table)
  end
end)

script.on_event("the418-kb--linked-confirm-gui", function(event)
  local Gui = player_gui.get_gui(event.player_index, "edit_topic")
  if Gui then
    Gui:dispatch({ action = "confirm", from = "custom-input" }, event)
  end
end)

script.on_event(defines.events.on_player_removed, function(event)
  global.players[event.player_index] = nil
end)

gui.hook_events(function(e)
  local msg = gui.read_action(e)
  if msg then
    local Gui = player_gui.get_gui(e.player_index, msg.gui)
    if Gui then
      Gui:dispatch(msg, e)
    end
  end
end)

-- handle GUIs being opened from other mods/scenarios
script.on_event(defines.events.on_gui_opened, function(event)
  if not event.element or event.element.get_mod() ~= "the418_kb" then
    local player_table = global.players[event.player_index]
    if player_table then
      for _, Gui in pairs(player_table.guis) do
        if Gui and Gui.refs.window.valid then
          Gui:close()
        end
      end
    end
  end

  local msg = gui.read_action(event)
  if msg then
    local Gui = player_gui.get_gui(event.player_index, msg.gui)
    if Gui then
      Gui:dispatch(msg, event)
    end
  end
end)
