local gui = require("__flib__/gui")
local on_tick_n = require("__flib__/on-tick-n")

local markup_events = require("__the418_kb__/markup/renderer/events")

local constants = require("__the418_kb__/constants")
local migrations = require("__the418_kb__/scripts/migrations")
local player_data = require("__the418_kb__/scripts/player-data")
local player_gui = require("__the418_kb__/scripts/player-gui")
local topic = require("__the418_kb__/scripts/topic")
local topic_tasks = require("__the418_kb__/scripts/topic-tasks")
local topics_gui_index = require("__the418_kb__/scripts/gui/main/index")
local edit_topic_gui_index = require("__the418_kb__/scripts/gui/edit-topic/index")
local confirm_delete_topic_gui_index =
  require("__the418_kb__/scripts/gui/confirm-delete-topic/index")

script.on_init(function()
  on_tick_n.init()

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

    if player_table.guis.confirm_delete_topic then
      confirm_delete_topic_gui_index.load(player_table.guis.confirm_delete_topic)
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
  player_data.refresh(player, global.players[event.player_index])
end)

--- @param player_index uint
local function toggle_interface(player_index)
  local TopicsGui = player_gui.get_gui(player_index, "topics")
  if TopicsGui then
    TopicsGui:toggle()
  else
    local player = game.get_player(player_index) --[[@as LuaPlayer]]
    local player_table = global.players[player_index]
    player_data.refresh(player, player_table)
  end
end

script.on_event("the418-kb--toggle-interface", function(event)
  toggle_interface(event.player_index)
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name == "the418-kb--toggle-interface" then
    toggle_interface(event.player_index)
  end
end)

script.on_event("the418-kb--linked-confirm-gui", function(event)
  local Gui = player_gui.get_gui(event.player_index, "edit_topic")
  if Gui then
    Gui:dispatch({ action = "confirm", from = "custom-input" }, event)
  end
end)

script.on_event(defines.events.on_tick, function(event)
  local tasks = on_tick_n.retrieve(event.tick)
  if tasks then
    for _, task in pairs(tasks) do
      if task.type == "parse_topic_body" then
        topic_tasks.handle(task)
      end
    end
  end

  if event.tick % constants.topic_lock_update_interval ~= 0 then
    return
  end

  -- Update topic locks
  for _, Topic in pairs(global.topics) do
    local Lock = Topic:get_lock()
    if Lock then
      if Lock.player.connected then
        -- Player is connected, update lock to reflect current tick
        Lock.tick = event.tick
      else
        -- Player is not connected, drop lock
        Topic:unlock()

        -- Clean up GUI
        local player_table = global.players[Lock.player.index]
        local Gui = player_table.guis.edit_topic
        if Gui then
          Gui:destroy()
        end

        -- Update GUI for all players
        player_gui.update_all_topics()
      end
    end
  end
end)

script.on_event(defines.events.on_player_removed, function(event)
  global.players[event.player_index] = nil

  for _, Topic in pairs(global.topics) do
    local Lock = Topic:get_lock()
    if Lock and Lock.player.index == event.player_index then
      Topic:unlock()
    end
  end
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
      local Gui = player_table.guis.topics
      if Gui and Gui.refs.window.valid then
        Gui:close()
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

script.on_event(defines.events.on_gui_click, function(event)
  -- TODO proper interface to hook markup events
  markup_events.handle_blueprint_click(event)

  -- fall back to flib gui
  local msg = gui.read_action(event)
  if msg then
    local Gui = player_gui.get_gui(event.player_index, msg.gui)
    if Gui then
      Gui:dispatch(msg, event)
    end
  end
end)
