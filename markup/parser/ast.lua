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

--- @class BlueprintBlock
--- @field kind "BLUEPRINT_BLOCK"
--- @field caption string?
--- @field value string
--- @field type SpecialItemType
--- @field blueprint_data table

--- @alias Block Heading | Paragraph | List | HorizontalRule | CodeBlock | BlueprintBlock

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

--- @class BlueprintInline
--- @field kind "BLUEPRINT_INLINE"
--- @field value string
--- @field type SpecialItemType
--- @field blueprint_data table

--- @class FactorioRichText
--- @field kind "RICH_TEXT"
--- @field key string
--- @field value string

--- @alias InlineContent Text | EmphasisedText | CodeInline | SoftBreak | LineBreak | BlueprintInline | FactorioRichText

--- @alias AST Block[]

local ast = {}

ast.KIND = {
  Paragraph = "PARAGRAPH",
  Heading = "HEADING",
  List = "LIST",
  ListItem = "LIST_ITEM",
  BlueprintBlock = "BLUEPRINT_BLOCK",
  Text = "TEXT",
  EmphasisedText = "EMPHASISED_TEXT",
  SoftBreak = "SOFT_BREAK",
  LineBreak = "LINE_BREAK",
  HorizontalRule = "HORIZONTAL_RULE",
  CodeInline = "CODE_INLINE",
  CodeBlock = "CODE_BLOCK",
  FactorioRichText = "RICH_TEXT",
  BlueprintInline = "BLUEPRINT_INLINE",
}

return ast
