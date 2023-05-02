local table = require("__flib__/table")

local lexer = require("__the418_kb__/markup/parser/lexer")
local parser = require("__the418_kb__/markup/parser/parser")
local renderer = require("__the418_kb__/markup/renderer/renderer")

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

local tasks = {}

--- @class ParseTask
--- @field ast Block[]
--- @field done boolean
--- @field parser Parser

--- @param input string
--- @return ParseTask
function tasks.create(input)
  local Lexer = lexer.new(input)
  local Parser = parser.new(Lexer)

  return { ast = {}, done = false, parser = Parser }
end

--- @param task ParseTask
--- @param steps integer
--- @return ParseTask
function tasks.perform(task, steps)
  local Parser = parser.load(task.parser)
  lexer.load(task.parser.lexer)

  local new_ast = table.shallow_copy(task.ast, true)

  for _ = 1, steps do
    local result = Parser:parse_document_step()

    if result == "DONE" then
      return { ast = new_ast, done = true, parser = Parser }
    elseif result then
      table.insert(new_ast, result)
    end
  end

  return { ast = new_ast, done = false, parser = Parser }
end

markup.tasks = tasks

return markup
