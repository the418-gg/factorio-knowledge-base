local ast = require("__the418_kb__/scripts/markup/parser/ast")
local token = require("__the418_kb__/scripts/markup/parser/token")

--- @class Parser
local Parser = {}

--- @return AST
function Parser:parse_document()
  --- @type AST
  local blocks = {}

  while self.current_token.kind ~= token.KIND.EOF do
    table.insert(blocks, self:parse_block())
    self:next_token()
  end

  return blocks
end

--- @package
function Parser:next_token()
  self.current_token = self.peek_token
  self.peek_token = self.lexer:next_token()
end

--- @private
--- @return Block
function Parser:parse_block()
  self:skip_empty_space()

  if self.current_token.kind == token.KIND.HeadingLevel1 then
    return self:parse_heading(1)
  elseif self.current_token.kind == token.KIND.HeadingLevel2 then
    return self:parse_heading(2)
  elseif self.current_token.kind == token.KIND.HeadingLevel3 then
    return self:parse_heading(3)
  else
    return self:parse_paragraph()
  end
end

--- @private
--- @param level 1 | 2 | 3
--- @return Heading
function Parser:parse_heading(level)
  self:next_token()
  return { kind = ast.KIND.Heading, level = level, children = self:parse_inline_content() }
end

--- @private
--- @return Paragraph
function Parser:parse_paragraph()
  return { kind = ast.KIND.Paragraph, children = self:parse_inline_content(true) }
end

--- @private
--- @param till_hard_break boolean?
--- @return InlineContent[]
function Parser:parse_inline_content(till_hard_break)
  local content = {}

  while true do
    if self.current_token.kind == token.KIND.Text then
      table.insert(content, { kind = ast.KIND.Text, text = self.current_token.value })
    elseif till_hard_break and self.current_token.kind == token.KIND.SoftBreak then
      -- ignore soft break
    else
      return content
    end

    self:next_token()
  end
end

--- @private
function Parser:skip_empty_space()
  while true do
    if
      self.current_token.kind == token.KIND.Space
      or self.current_token.kind == token.KIND.SoftBreak
    then
      self:next_token()
    else
      break
    end
  end
end

local parser = {}

--- @param lexer Lexer
--- @return Parser
function parser.new(lexer)
  --- @class Parser
  local self = {
    lexer = lexer,
    current_token = { kind = token.KIND.EOF }, --- @type Token
    peek_token = { kind = token.KIND.EOF }, --- @type Token
  }
  setmetatable(self, { __index = Parser })

  -- initialise current and peek tokens
  self:next_token()
  self:next_token()

  return self
end

return parser
