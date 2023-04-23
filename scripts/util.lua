local util = {}

--- @generic V
--- @param tbl table<_, V>
--- @param value V
--- @return boolean
function util.has_value(tbl, value)
  for _, v in ipairs(tbl) do
    if value == v then
      return true
    end
  end

  return false
end

--- @generic V
--- @param tbl table<_, V>
--- @param value V
function util.remove_value(tbl, value)
  for pos, v in ipairs(tbl) do
    if value == v then
      table.remove(tbl, pos)
    end
  end
end

--- @generic K: number
--- @generic V
--- @param tbl table<K, V>
--- @return V[]
function util.to_array(tbl)
  local result = {}

  for _, v in ipairs(tbl) do
    table.insert(result, v)
  end

  return result
end

--- @param player LuaPlayer
--- @param text LocalisedString
function util.error_text(player, text)
  player.create_local_flying_text({
    create_at_cursor = true,
    text = text,
  })
  player.play_sound({ path = "utility/cannot_build" })
end

--- @param prev_selected_id integer?
--- @return Topic?
function util.get_first_valid_topic(prev_selected_id)
  local Topic = global.topics[prev_selected_id]
  if Topic then
    return Topic
  else
    for _, v in ipairs(global.topics) do
      return v
    end
  end
end

return util
