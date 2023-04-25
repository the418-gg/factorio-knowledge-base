local token = require("__the418_kb__/scripts/markup/parser/token")

--- @class Lexer
local Lexer = {}

--- @return Token
function Lexer:next_token()
  self:skip_empty_space()

  local tok = self:get_current_token()
  game.print("TOK" .. serpent.line(tok))
  self:read_char()
  return tok
end

--- @return Token
function Lexer:get_current_token()
  if self.current_char == "\n" then
    if self:peek_char() == "\n" then
      self:read_char()
      return { kind = token.KIND.HardBreak }
    end
    return { kind = token.KIND.SoftBreak }
  elseif self.current_char == " " then
    return { kind = token.KIND.Space }
  elseif self.current_char == "#" then
    return self:try_read_heading()
  elseif self.current_char == "*" then
    return { kind = token.KIND.Asterisk }
  elseif self.current_char == ">" then
    return { kind = token.KIND.Gt }
  elseif self.current_char == "" then
    return { kind = token.KIND.EOF }
  else
    return { kind = token.KIND.Text, value = self:read_text() }
  end
end

--- @package
function Lexer:read_char()
  if self.read_position > #self.input then
    self.current_char = ""
  else
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
        return { kind = token.KIND.Text, value = "##" .. self:read_text() }
      end
    elseif self:peek_char() == " " then
      self:read_char()
      return { kind = token.KIND.HeadingLevel2 }
    else
      return { kind = token.KIND.Text, value = "#" .. self:read_text() }
    end
  elseif self:peek_char() == " " then
    self:read_char()
    return { kind = token.KIND.HeadingLevel1 }
  else
    self:read_char()
    return { kind = token.KIND.Text, value = self:read_text() }
  end
end

--- @private
--- @return string
function Lexer:read_text()
  local text = ""

  while true do
    text = text .. self.current_char --- @type string
    if self:peek_char() == "\n" or self:peek_char() == "" then
      return text
    end

    self:read_char()
  end
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
  }

  setmetatable(self, { __index = Lexer })
  self:read_char()

  return self
end

return lexer
