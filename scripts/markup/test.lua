local lexer = require("__the418_kb__/scripts/markup/parser/lexer")
local parser = require("__the418_kb__/scripts/markup/parser/parser")

local test = {}

--- @param input string
function test.test(input)
  local Lexer = lexer.new(input)
  local Parser = parser.new(Lexer)

  game.print(serpent.block(Parser:parse_document()))
end

--- @param input string
--- @return AST
function test.parse(input)
  local Lexer = lexer.new(input)
  local Parser = parser.new(Lexer)

  return Parser:parse_document()
end

return test
