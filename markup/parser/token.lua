local token = {}

--- @enum TokenKind
token.KIND = {
  Illegal = "__ILLEGAL__",
  EOF = "",
  -- Delimiters
  SoftBreak = "\n",
  HardBreak = "\n\n",
  LineBreak = "\\\n",
  Space = " ",
  DoubleWhitespace = "  ",
  -- Input
  Text = "__TEXT__",
  -- Formatting tokens
  HeadingLevel1 = "#",
  HeadingLevel2 = "##",
  HeadingLevel3 = "###",
  EmphasisBold = "**",
  ListItemUnordered = "-",
  ListItemOrdered = "__LIST_ITEM_ORDERED__",
  HorizontalRule = "---",
}

--- @class Token
--- @field kind TokenKind
--- @field value string?

--- @param tok Token
--- @return string
function token.to_string(tok)
  if tok.kind == token.KIND.Illegal then
    error("Cannot stringify illegal token")
  elseif tok.kind == token.KIND.Text then
    return tok.value or ""
  else
    return tok.kind
  end
end

return token
