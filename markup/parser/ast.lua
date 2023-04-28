--- @class Heading
--- @field kind "HEADING"
--- @field level 1 | 2 | 3
--- @field children InlineContent[]

--- @class Paragraph
--- @field kind "PARAGRAPH"
--- @field children InlineContent[]

--- @alias ListType "ORDERED" | "UNORDERED"

--- @class List
--- @field kind "LIST"
--- @field level uint
--- @field list_type ListType
--- @field items Paragraph[]

--- @alias Block Heading | Paragraph | List

--- @class Text
--- @field kind "TEXT"
--- @field text string

--- @alias TextEmphasis "BOLD"

--- @class EmphasisedText
--- @field kind "EMPHASISED_TEXT"
--- @field emphasis TextEmphasis
--- @field children InlineContent[]

--- @class SoftBreak
--- @field kind "SOFT_BREAK"

--- @class LineBreak
--- @field kind "LINE_BREAK"

--- @alias InlineContent Text | EmphasisedText | SoftBreak | LineBreak

--- @alias AST Block[]

local ast = {}

ast.KIND = {
  Paragraph = "PARAGRAPH",
  Heading = "HEADING",
  List = "LIST",
  Text = "TEXT",
  EmphasisedText = "EMPHASISED_TEXT",
  SoftBreak = "SOFT_BREAK",
  LineBreak = "LINE_BREAK",
}

return ast
