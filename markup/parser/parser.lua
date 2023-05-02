local ast = require("__the418_kb__/markup/parser/ast")
local token = require("__the418_kb__/markup/parser/token")

local LIST_TYPE_TOKEN_MAPPING = {
  ORDERED = token.KIND.ListItemOrdered,
  UNORDERED = token.KIND.ListItemUnordered,
}

--- @class Parser
local Parser = {}

--- @return AST
function Parser:parse_document()
  --- @type AST
  local blocks = {}

  while self.current_token.kind ~= token.KIND.EOF do
    local block = self:parse_block()
    if block then
      table.insert(blocks, block)
    end
  end

  return blocks
end

--- @return (Block | nil | "DONE")
function Parser:parse_document_step()
  if self.current_token.kind == token.KIND.EOF then
    return "DONE"
  end

  local block = self:parse_block()
  if block then
    return block
  end
end

--- @package
function Parser:next_token()
  self.current_token = self.peek_token
  self.peek_token = self.lexer:next_token()
end

--- @private
--- @return Block?
function Parser:parse_block()
  self:skip_empty_space()

  if self.current_token.kind == token.KIND.HeadingLevel1 then
    return self:parse_heading(1)
  elseif self.current_token.kind == token.KIND.HeadingLevel2 then
    return self:parse_heading(2)
  elseif self.current_token.kind == token.KIND.HeadingLevel3 then
    return self:parse_heading(3)
  elseif self.current_token.kind == token.KIND.ListItemUnordered then
    return self:parse_list("UNORDERED")
  elseif self.current_token.kind == token.KIND.ListItemOrdered then
    return self:parse_list("ORDERED")
  elseif self.current_token.kind == token.KIND.HardBreak then
    self:next_token()
  elseif self.current_token.kind == token.KIND.HorizontalRule then
    self:next_token()
    return { kind = ast.KIND.HorizontalRule }
  elseif self.current_token.kind == token.KIND.CodeBlock then
    local result = { kind = ast.KIND.CodeBlock, text = self.current_token.value }
    self:next_token()
    return result
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
--- @param list_type ListType
--- @return List
function Parser:parse_list(list_type)
  local items = {} --- @type Block[]
  local list_token = LIST_TYPE_TOKEN_MAPPING[list_type]

  local level = self.list_context.level
  local list_item_order = 1 --- @type uint

  while true do
    if self.list_context.double_whitespace_eaten then
      self.list_context.double_whitespace_eaten = false
      -- indentation already eaten for the first item
      if self.current_token.kind == token.KIND.DoubleWhitespace then
        -- try with indentation + 1
        self.list_context.level = self.list_context.level + 1
        local item = self:parse_list_item(list_item_order)
        if item then
          if item.kind == "LIST_ITEM" then
            list_item_order = list_item_order + 1
          end
          table.insert(items, item)
        end
      elseif self.current_token.kind == list_token then
        if self.list_context.level == level then
          self:next_token()
          local item = self:parse_list_item(list_item_order)
          if item then
            if item.kind == "LIST_ITEM" then
              list_item_order = list_item_order + 1
            end
            table.insert(items, item)
          end
        else
          -- if we were too deep, return
          local result = {
            kind = ast.KIND.List,
            level = level,
            list_type = list_type,
            items = items,
          }
          return result
        end
      end
    end

    -- try with current indentation
    for i = 1, self.list_context.level - 1 do
      if self.current_token.kind == token.KIND.DoubleWhitespace then
        self:next_token()
      else
        -- indentation smaller than expected, end list
        self.list_context.double_whitespace_eaten = true
        local result = {
          kind = ast.KIND.List,
          level = level,
          list_type = list_type,
          items = items,
        }
        self.list_context.level = i
        return result
      end
    end

    if self.current_token.kind == token.KIND.DoubleWhitespace then
      self.list_context.double_whitespace_eaten = true
      -- try with indentation + 1
      self.list_context.level = self.list_context.level + 1
      self:next_token()
      local item = self:parse_list_item(list_item_order)
      if item then
        if item.kind == "LIST_ITEM" then
          list_item_order = list_item_order + 1
        end
        table.insert(items, item)
      end
    elseif self.current_token.kind == list_token then
      self:next_token()
      local item = self:parse_list_item(list_item_order)
      if item then
        if item.kind == "LIST_ITEM" then
          list_item_order = list_item_order + 1
        end
        table.insert(items, item)
      end
    else
      break
    end
  end

  return { kind = ast.KIND.List, level = level, list_type = list_type, items = items }
end

--- @private
--- @param order uint
--- @return (ListItem | List)?
function Parser:parse_list_item(order)
  local block = self:parse_block()
  if not block then
    return
  end

  if block.kind == "LIST" then
    return block --[[@as List]]
  else
    return { kind = ast.KIND.ListItem, order = order, content = block }
  end
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
    elseif self.current_token.kind == token.KIND.DoubleWhitespace then
      return block
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
    elseif self.current_token.kind == token.KIND.CodeInline then
      local is_first_line = true
      for line in string.gmatch(self.current_token.value, "[^\r^\n]+") do
        if not is_first_line then
          table.insert(block, { kind = ast.KIND.LineBreak })
        end
        table.insert(block, { kind = ast.KIND.CodeInline, text = line })
        is_first_line = false
      end

      if is_first_line then
        -- empty block
        table.insert(block, { kind = ast.KIND.CodeInline, text = self.current_token.value })
      end
    else
      local content = self:parse_inline_content()
      if content then
        table.insert(block, content)
      else
        if till_token then
          -- till_token block not finished
          table.insert(block, 1, { kind = ast.KIND.Text, text = token.value })
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
  elseif self.current_token.kind == token.KIND.RichText then
    return self:parse_rich_text()
  elseif self.current_token.kind == token.KIND.SoftBreak then
    return { kind = ast.KIND.SoftBreak }
  elseif self.current_token.kind == token.KIND.LineBreak then
    return { kind = ast.KIND.LineBreak }
  end
end

--- @private
--- @return InlineContent
function Parser:parse_rich_text()
  local key = self.current_token.value.key
  local value = self.current_token.value.value

  if key == "special-item" then
    -- Blueprint. TODO cannot unit test this! Need to mock `game` or use dependency injection
    local decoded_bpstring = game.decode_string(string.sub(value, 2)) -- need to ignore the first (version) byte
    local parsed_blueprint = decoded_bpstring and game.json_to_table(decoded_bpstring) --[[@as table]]
      or nil

    if not parsed_blueprint then
      return {
        kind = ast.KIND.FactorioRichText,
        key = self.current_token.value.key,
        value = self.current_token.value.value,
      }
    end

    local type = next(parsed_blueprint)
    -- TODO check type?

    -- Blueprint
    return {
      kind = ast.KIND.Blueprint,
      value = value,
      type = type,
      blueprint_data = parsed_blueprint,
    }
  else
    return {
      kind = ast.KIND.FactorioRichText,
      key = self.current_token.value.key,
      value = self.current_token.value.value,
    }
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
    --- @class ParserListContext
    list_context = {
      level = 1,
      double_whitespace_eaten = false,
    },
  }
  setmetatable(self, { __index = Parser })

  -- initialise current and peek tokens
  self:next_token()
  self:next_token()

  return self
end

--- @param self Parser
--- @return Parser
function parser.load(self)
  setmetatable(self, { __index = Parser })
  return self
end

return parser
