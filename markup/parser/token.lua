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
  -- Block-level tokens
  HeadingLevel1 = "#",
  HeadingLevel2 = "##",
  HeadingLevel3 = "###",
  HorizontalRule = "---",
  ListItemUnordered = "-",
  ListItemOrdered = "__LIST_ITEM_ORDERED__",
  CodeBlock = "```",
  -- Inline-level tokens
  EmphasisBold = "**",
  CodeInline = "`",
  RichText = "__RICH_TEXT__",
}

--- @class Token
--- @field kind TokenKind
--- @field value any

return token
