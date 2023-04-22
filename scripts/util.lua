local util = {}

--- @param tbl table
--- @param value any
--- @return boolean
function util.has_value(tbl, value)
  for _, v in ipairs(tbl) do
    if value == v then
      return true
    end
  end

  return false
end

--- @param tbl table
--- @param value any
function util.remove_value(tbl, value)
  for pos, v in ipairs(tbl) do
    if value == v then
      table.remove(tbl, pos)
    end
  end
end

--- @param tbl table
--- @return table
function util.to_array(tbl)
  local result = {}

  for _, v in ipairs(tbl) do
    table.insert(result, v)
  end

  return result
end

return util
