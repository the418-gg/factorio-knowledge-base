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
  return { kind = ast.KIND.Heading, level = level, children = self:parse_inline_content_block() }
end

--- @private
--- @return Paragraph
function Parser:parse_paragraph()
  return { kind = ast.KIND.Paragraph, children = self:parse_inline_content_block(true) }
end

--- @private
--- @param till_hard_break boolean?
--- @param till_token Token?
--- @return InlineContent[]
function Parser:parse_inline_content_block(till_hard_break, till_token)
  local block = {}

  while true do
    if till_hard_break and self.current_token.kind == token.KIND.SoftBreak then
      table.insert(block, { kind = ast.KIND.SoftBreak })
    elseif self.current_token.kind == token.KIND.EmphasisBold then
      if till_token and till_token.kind == token.KIND.EmphasisBold then
        -- finish bold block
        return { { kind = ast.KIND.EmphasisedText, emphasis = "BOLD", children = block } }
      else
        -- start bold block
        self:next_token()
        for _, c in
          pairs(
            self:parse_inline_content_block(till_hard_break, { kind = token.KIND.EmphasisBold })
          )
        do
          table.insert(block, c)
        end
      end
    else
      local content = self:parse_inline_content()
      if content then
        table.insert(block, content)
      else
        if till_token then
          -- till_token block not finished
          table.insert(block, 1, { kind = ast.KIND.Text, text = token.to_string(till_token) })
        end
        return block
      end
    end

    self:next_token()
  end
end

--- @private
--- @return InlineContent?
function Parser:parse_inline_content()
  if self.current_token.kind == token.KIND.Text then
    return { kind = ast.KIND.Text, text = self.current_token.value }
  elseif self.current_token.kind == token.KIND.SoftBreak then
    return { kind = ast.KIND.SoftBreak }
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
