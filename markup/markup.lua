local lexer = require("__the418_kb__/markup/parser/lexer")
local parser = require("__the418_kb__/markup/parser/parser")
local renderer = require("__the418_kb__/markup/renderer")

local markup = {}

--- @param input string
--- @return AST
function markup.parse(input)
  local Lexer = lexer.new(input)
  local Parser = parser.new(Lexer)

  return Parser:parse_document()
end

--- @param Ast AST
--- @return LuaGuiElement
function markup.render(Ast)
  return renderer.from_ast(Ast)
end

return markup
