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

--- @class EmphasisedText
--- @field kind "EMPHASISED_TEXT"
--- @field children InlineContent[]

--- @alias InlineContent Text | EmphasisedText

--- @alias AST Block[]

local ast = {}

ast.KIND = {
  Paragraph = "PARAGRAPH",
  Heading = "HEADING",
  Text = "TEXT",
  EmphasisedText = "EMPHASISED_TEXT",
}

-- Heading {level=1..3, children}
-- Paragraph {children}
-- Text {children}
-- Italics {children}
-- Bold {children}
-- Blockquote {children}

return ast
