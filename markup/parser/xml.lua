local xml_parser = require("__the418_kb__/markup/vendor/simple-xml-parser")

local xml = {}

--- @param input string
--- @return table, integer
function xml.parse(input)
  return xml_parser.parse(input)
end

return xml
