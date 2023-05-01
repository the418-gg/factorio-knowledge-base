local lexer = require("__the418_kb__/markup/parser/lexer")
local parser = require("__the418_kb__/markup/parser/parser")

local markup = {}

--- @param input string
--- @return AST
function markup.parse(input)
  local Lexer = lexer.new(input)
  local Parser = parser.new(Lexer)

  return Parser:parse_document()
end

return markup
