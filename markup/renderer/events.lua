local events = {}

-- TODO remove flib dependency? (see tags)
--- @param event EventData.on_gui_click
function events.handle_blueprint_click(event)
  local mod_tags = event.element.tags.the418_kb
  if not mod_tags then
    return
  end
  local blueprint_string = mod_tags["the418_kb__markup__blueprint_string"]
  if not blueprint_string then
    return
  end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local item_stack = player.cursor_stack

  if not item_stack then
    return
  end

  item_stack.import_stack(blueprint_string --[[@as string]])
end

return events
