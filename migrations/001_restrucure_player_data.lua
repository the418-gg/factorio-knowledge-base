local player_data = require("__the418_kb__/scripts/player-data")
local migrations = require("__the418_kb__/scripts/migrations")

for i, player_table in pairs(global.players) do
  player_table.selected_topic_id = nil
  player_table.gui_stack = nil

  local player = game.get_player(i) --[[@as LuaPlayer]]
  player_data.init(player)

  if player.opened and player.opened.get_mod() == "the418_kb" then
    player.opened.destroy()
    player.opened = nil
  end

  migrations.generic()
end
