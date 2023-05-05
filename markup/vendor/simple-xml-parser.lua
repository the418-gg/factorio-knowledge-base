--- Copied and modified from Roberto Ierusalimschy's code found here: http://lua-users.org/wiki/LuaXml

local xml = {}

--- @param s string
--- @return table
local function parse_args(s)
  local arg = {}
  --- @diagnostic disable-next-line
  string.gsub(s, "([%-%w]+)=([\"'])(.-)%2", function(w, _, a)
    arg[w] = a
  end)
  return arg
end

--- @param s string
--- @return string
local function trim_string(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

--- @param input string
--- @return table, integer
function xml.parse(input)
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni, c, label, xarg, empty
  local i, j = 1, 1
  local len = 0
  while true do
    -- MODIFICATION: the pattern is modified to support hyphens inside of XML tags
    ni, j, c, label, xarg, empty = string.find(input, "<(%/?)([%w:%-]+)(.-)(%/?)>", i)
    if not ni then
      break
    end
    local text = string.sub(input, i, ni - 1)
    len = len + j - ni + 1 + #text
    text = trim_string(text)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then -- empty element tag
      table.insert(top, { label = label, xarg = parse_args(xarg), empty = 1 })
    elseif c == "" then -- start tag
      top = { label = label, xarg = parse_args(xarg) }
      table.insert(stack, top) -- new level
    else -- end tag
      local toclose = table.remove(stack) -- remove top
      top = stack[#stack]
      if #stack < 1 then
        -- MODIFICATION: no error, just return nothing if XML is invalid
        -- error("nothing to close with " .. label)
        return {}, 0
      end
      if toclose.label ~= label then
        -- MODIFICATION: no error, just return nothing if XML is invalid
        -- error("trying to close " .. toclose.label .. " with " .. label)
        return {}, 0
      end
      table.insert(top, toclose)
      -- MODIFICATION: Add a check to see if the top element is the first element
      if #stack == 1 then
        -- If it is, break out of the loop and return the parsed element
        return stack[1], len
      end
    end
    i = j + 1
  end
  local text = trim_string(string.sub(input, i))
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    -- MODIFICATION: no error, just return nothing if XML is invalid
    -- error("unclosed " .. stack[#stack].label)
    return {}, 0
  end
  return stack[1], #input
end

return xml
