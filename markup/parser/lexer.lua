local xml = require("__the418_kb__/markup/parser/xml")
local token = require("__the418_kb__/markup/parser/token")

--- @class Lexer
local Lexer = {}

--- @return Token
function Lexer:next_token()
  self:skip_empty_space()

  local tok = self:get_current_token()
  self:read_char()
  return tok
end

--- @param is_escaped true?
--- @return Token
function Lexer:get_current_token(is_escaped)
  if self.current_char == "" then
    return { kind = token.KIND.EOF }
  elseif self.current_char == "\\" then
    self:read_char()
    return self:get_current_token(true)
  elseif self.is_block_level_context and self.current_char == " " and self:peek_char() == " " then
    self:read_char()
    self.is_block_level_context = true
    return { kind = token.KIND.DoubleWhitespace }
  elseif self.is_block_level_context and self.current_char == "#" then
    return self:try_read_heading()
  elseif self.is_block_level_context and self.current_char == "-" then
    if self:peek_char() == " " then
      self:read_char()
      self.is_block_level_context = true
      return { kind = token.KIND.ListItemUnordered }
    elseif self:peek_char() == "-" then
      return self:try_read_horizontal_rule()
    else
      return { kind = token.KIND.Text, value = self:read_text() }
    end
  elseif self.is_block_level_context and self.current_char == "`" then
    if self:peek_char() == "`" then
      return self:try_read_code_block()
    else
      return self:try_read_inline_code()
    end
  elseif self.is_block_level_context and self:current_char_is_digit() then
    return self:try_read_ordered_list_item()
  elseif self.is_block_level_context and self.current_char == "\n" then
    return { kind = token.KIND.HardBreak }
  elseif self.is_block_level_context and self.current_char == "<" then
    return self:try_read_xml_style_block()
  elseif self.current_char == "\n" then
    if is_escaped then
      return { kind = token.KIND.LineBreak }
    end
    if self:peek_char() == "\n" then
      self:read_char()
      return { kind = token.KIND.HardBreak }
    end
    return { kind = token.KIND.SoftBreak }
  elseif not is_escaped then
    if self.current_char == "*" and self:peek_char() == "*" then
      self:read_char()
      return { kind = token.KIND.EmphasisBold }
    elseif self.current_char == "`" then
      return self:try_read_inline_code()
    elseif self.current_char == "[" then
      return self:try_read_rich_text_item()
    else
      return { kind = token.KIND.Text, value = self:read_text() }
    end
  else
    return { kind = token.KIND.Text, value = self:read_text() }
  end
end

--- @package
function Lexer:read_char()
  if self.read_position > #self.input then
    self.current_char = ""
  else
    self.is_block_level_context = self.current_char == "\n"
      or self.current_char == ""
      or (self.is_block_level_context and self.current_char == " ")
    self.current_char = string.sub(self.input, self.read_position, self.read_position)
  end

  self.position = self.read_position
  self.read_position = self.read_position + 1
end

--- @private
--- @return Token
function Lexer:try_read_heading()
  if self:peek_char() == "#" then
    -- Level 2?
    self:read_char()
    if self:peek_char() == "#" then
      -- Level 3?
      self:read_char()
      if self:peek_char() == " " then
        self:read_char()
        return { kind = token.KIND.HeadingLevel3 }
      else
        self:read_char()
        return { kind = token.KIND.Text, value = "###" .. self:read_text() }
      end
    elseif self:peek_char() == " " then
      self:read_char()
      return { kind = token.KIND.HeadingLevel2 }
    else
      self:read_char()
      return { kind = token.KIND.Text, value = "##" .. self:read_text() }
    end
  elseif self:peek_char() == " " then
    self:read_char()
    return { kind = token.KIND.HeadingLevel1 }
  else
    self:read_char()
    return { kind = token.KIND.Text, value = "#" .. self:read_text() }
  end
end

--- @private
--- @return Token
function Lexer:try_read_ordered_list_item()
  local initial_position = self.position
  while self:current_char_is_digit() do
    self:read_char()
  end

  if self.current_char == "." and self:peek_char() == " " then
    self:read_char()
    self.is_block_level_context = true
    return {
      kind = token.KIND.ListItemOrdered,
      value = string.sub(self.input, initial_position, self.position - 2),
    }
  else
    return {
      kind = token.KIND.Text,
      value = string.sub(self.input, initial_position, self.position - 1) .. self:read_text(),
    }
  end
end

--- @private
--- @return Token
function Lexer:try_read_horizontal_rule()
  local initial_position = self.position
  self:read_char() -- first '-'
  if self:peek_char() == "-" then
    self:read_char() -- second '-'
    if self:peek_char() == "\n" or self:peek_char() == "" then
      return { kind = token.KIND.HorizontalRule }
    end
  end

  return {
    kind = token.KIND.Text,
    value = string.sub(self.input, initial_position, self.position - 1) .. self:read_text(),
  }
end

--- @private
--- @return Token
function Lexer:try_read_inline_code()
  local initial_position = self.position
  self:read_char() -- opening '`'

  while self.current_char ~= "`" do
    if self.current_char == "" then
      self.position = initial_position
      self.read_position = initial_position + 1
      return {
        kind = token.KIND.Text,
        value = self:read_text(),
      }
    end
    self:read_char()
  end

  return {
    kind = token.KIND.CodeInline,
    value = string.sub(self.input, initial_position + 1, self.position - 1),
  }
end

--- @private
--- @return Token
function Lexer:try_read_code_block()
  local initial_position = self.position
  self:read_char() -- first '`'
  if self:peek_char() == "`" then
    self:read_char() -- second '`'
    if self:peek_char() == "\n" then
      self:read_char()
      while true do
        if self.current_char == "" then
          local result = {
            kind = token.KIND.CodeBlock,
            value = string.sub(self.input, initial_position + 4, self.position),
          }
          return result
        elseif self.current_char == "`" and self:peek_char() == "`" then
          self:read_char()
          if self:peek_char() == "`" then
            self:read_char()
            if self:peek_char() == "\n" or self:peek_char() == "" then
              self:read_char()
              return {
                kind = token.KIND.CodeBlock,
                value = string.sub(self.input, initial_position + 4, self.position - 5),
              }
            end
          end
        end
        self:read_char()
      end
    end
  end

  return {
    kind = token.KIND.Text,
    value = string.sub(self.input, initial_position, self.position - 1) .. self:read_text(),
  }
end

--- @private
--- @return Token
function Lexer:try_read_xml_style_block()
  local parsed, len = xml.parse(string.sub(self.input, self.position))
  local node = parsed[1]

  if len == 0 or not node or node.label ~= "special-item" then
    return {
      kind = token.KIND.Text,
      value = self:read_text(),
    }
  end

  game.print("parsign xml, len = " .. len)
  local name = (node.xarg or {}).name
  self.position = self.position + len - 2
  self.read_position = self.position + 1
  self:read_char()
  game.print("parsed")
  return {
    kind = token.KIND.SpecialItemBlock,
    value = { name = name, value = node[1] },
  }
end

--- @private
--- @return Token
function Lexer:try_read_rich_text_item()
  local key, value =
    string.match(string.sub(self.input, self.position), "^%[([%a%-]+)=([^\n^%]]+)%]")

  if key and value then
    self.position = self.position + #key + #value + 2 -- ([ + #key + = + #value + ]) - 1
    self.read_position = self.position + 1
    self:read_char()
    return { kind = token.KIND.RichText, value = { key = key, value = value } }
  else
    return { kind = token.KIND.Text, value = self:read_text() }
  end
end

--- @private
--- @return string
function Lexer:read_text()
  local text = ""

  text = string.gsub(string.sub(self.input, self.position), "([^*^\n^\\^`^%[]+)(.*)", "%1")

  self.position = self.position + #text - 2
  self.read_position = self.position + 1
  self:read_char()

  return text
end

--- @private
--- @return string
function Lexer:peek_char()
  if self.read_position > #self.input then
    return ""
  else
    return string.sub(self.input, self.read_position, self.read_position)
  end
end

--- @private
function Lexer:skip_empty_space()
  while true do
    if self.current_char == "\t" or self.current_char == "\r" then
      self:read_char()
    else
      break
    end
  end
end

--- @private
function Lexer:skip_whitespace()
  while true do
    if self.current_char == " " then
      self:read_char()
    else
      break
    end
  end
end

--- @return boolean
--- @private
function Lexer:current_char_is_digit()
  return self.current_char == "0"
    or self.current_char == "1"
    or self.current_char == "2"
    or self.current_char == "3"
    or self.current_char == "4"
    or self.current_char == "5"
    or self.current_char == "6"
    or self.current_char == "7"
    or self.current_char == "8"
    or self.current_char == "9"
end

local lexer = {}

--- @param input string
--- @return Lexer
function lexer.new(input)
  --- @class Lexer
  local self = {
    input = input,
    position = 1,
    read_position = 1,
    current_char = "",
    is_block_level_context = true,
  }

  setmetatable(self, { __index = Lexer })
  self:read_char()

  return self
end

--- @param self Lexer
function lexer.load(self)
  setmetatable(self, { __index = Lexer })
end

return lexer
