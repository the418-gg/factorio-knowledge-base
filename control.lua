local gui = require("__flib__/gui")
local gui_stack = require("__the418_kb__/scripts/gui/stack")
local guis = require("__the418_kb__/scripts/gui/guis")

--- @param player LuaPlayer
local function initialize_player_data(player)
  global.players[player.index] = {
    selected_topic_id = global.public.top_level_topic_ids[1],
    gui_stack = gui_stack.new(),
  }
end

--- @class Topic
--- @field id number
--- @field title string
--- @field body string
--- @field child_ids number[]

script.on_init(function()
  global.public = {
    top_level_topic_ids = { 1 },
  }
  global.players = {}

  global.topics = {
    [1] = { id = 1, title = "Welcome", body = "Hello world", child_ids = {} },
  }
  global.next_topic_id = #global.topics + 1

  for _, player in pairs(game.players) do
    initialize_player_data(player)
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  initialize_player_data(player)
end)

script.on_event("the418-kb--toggle-interface", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  guis.main.toggle(player, guis)
end)

script.on_event("the418-kb--linked-confirm-gui", function(event)
  local player_gui = global.players[event.player_index].gui_stack
  local current_gui = gui_stack.current(player_gui)

  if current_gui and current_gui.refs.window.name == "the418_kb__edit_topic_window" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

    current_gui.handle_event({ action = "confirm", gui = "edit_topic",
      from = "custom-input" })
    player.play_sound({ path = "utility/confirm" })
  end
end)

script.on_event(defines.events.on_player_removed, function(event)
  global.players[event.player_index] = nil
end)

gui.hook_events(function(e)
  local msg = gui.read_action(e)
  if msg then
    local player_gui = global.players[e.player_index].gui_stack
    local current_gui = gui_stack.current(player_gui)

    if current_gui then
      current_gui.handle_event(msg)
    end
  end
end)

-- handle GUIs being opened from other mods/scenarios
script.on_event(defines.events.on_gui_opened, function(event)
  local player_gui = global.players[event.player_index].gui_stack
  local current_gui = gui_stack.current(player_gui)

  if not event.element or event.element.get_mod() ~= "the418_kb" then
    while (current_gui) do
      current_gui.refs.window.destroy()
      gui_stack.pop(player_gui)
      current_gui = gui_stack.current(player_gui)
    end
    return
  end

  local msg = gui.read_action(event)
  if msg and current_gui then
    current_gui.handle_event(msg)
  end
end)
