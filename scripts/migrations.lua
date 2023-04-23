local player_data = require("__the418_kb__/scripts/player-data")

local migrations = {}

function migrations.generic()
  for i, player_table in pairs(global.players) do
    local player = game.get_player(i) --[[@as LuaPlayer]]
    player_data.refresh(player, player_table)
  end
end

return migrations
