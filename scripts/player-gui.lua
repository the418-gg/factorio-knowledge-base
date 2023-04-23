local player_gui = {}

--- @param player_index uint
--- @param gui_name "topics" | "edit_topic"
--- @return (TopicsGui | EditTopicsGui)?
function player_gui.get_gui(player_index, gui_name)
  local player_table = global.players[player_index]
  if player_table then
    local Gui = player_table.guis[gui_name]
    if Gui and Gui.refs.window.valid then
      return Gui
    end
  end
end

return player_gui
