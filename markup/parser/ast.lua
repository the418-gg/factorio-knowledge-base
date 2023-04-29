--- @class Heading
--- @field kind "HEADING"
--- @field level 1 | 2 | 3
--- @field children InlineContent[]

--- @class Paragraph
--- @field kind "PARAGRAPH"
--- @field children InlineContent[]

--- @alias List OrderedList | UnorderedList
--- @alias ListType "ORDERED" | "UNORDERED"

--- @class OrderedList
--- @field kind "LIST"
--- @field level uint
--- @field list_type "ORDERED"
--- @field items (List | ListItem)[]

--- @class UnorderedList
--- @field kind "LIST"
--- @field level uint
--- @field list_type "UNORDERED"
--- @field items (List | ListItem)[]

--- @class ListItem
--- @field kind "LIST_ITEM"
--- @field order uint
--- @field content Block

--- @class HorizontalRule
--- @field kind "HORIZONTAL_RULE"

--- @class CodeBlock
--- @field text string

--- @alias Block Heading | Paragraph | List | HorizontalRule | CodeBlock

--- @class Text
--- @field kind "TEXT"
--- @field text string

--- @alias TextEmphasis "BOLD"

--- @class EmphasisedText
--- @field kind "EMPHASISED_TEXT"
--- @field emphasis TextEmphasis
--- @field children InlineContent[]

--- @class CodeInline
--- @field kind "CODE_INLINE"
--- @field text string

--- @class SoftBreak
--- @field kind "SOFT_BREAK"

--- @class LineBreak
--- @field kind "LINE_BREAK"

--- @alias InlineContent Text | EmphasisedText | CodeInline | SoftBreak | LineBreak

--- @alias AST Block[]

local ast = {}

ast.KIND = {
  Paragraph = "PARAGRAPH",
  Heading = "HEADING",
  List = "LIST",
  ListItem = "LIST_ITEM",
  Text = "TEXT",
  EmphasisedText = "EMPHASISED_TEXT",
  SoftBreak = "SOFT_BREAK",
  LineBreak = "LINE_BREAK",
  HorizontalRule = "HORIZONTAL_RULE",
  CodeInline = "CODE_INLINE",
  CodeBlock = "CODE_BLOCK",
}

return ast
