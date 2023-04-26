--- @class Heading
--- @field kind "HEADING"
--- @field level 1 | 2 | 3
--- @field children InlineContent[]

--- @class Paragraph
--- @field kind "PARAGRAPH"
--- @field children InlineContent[]

--- @alias Block Heading | Paragraph

--- @class Text
--- @field kind "TEXT"
--- @field text string

--- @alias TextEmphasis "BOLD" | "ITALIC"

--- @class EmphasisedText
--- @field kind "EMPHASISED_TEXT"
--- @field emphasis TextEmphasis
--- @field children InlineContent[]

--- @class SoftBreak
--- @field kind "SOFT_BREAK"

--- @alias InlineContent Text | EmphasisedText | SoftBreak

--- @alias AST Block[]

local ast = {}

ast.KIND = {
  Paragraph = "PARAGRAPH",
  Heading = "HEADING",
  Text = "TEXT",
  EmphasisedText = "EMPHASISED_TEXT",
  SoftBreak = "SOFT_BREAK",
}

-- Heading {level=1..3, children}
-- Paragraph {children}
-- Text {children}
-- Italics {children}
-- Bold {children}
-- Blockquote {children}

return ast
