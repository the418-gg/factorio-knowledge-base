local table = require("__flib__/table")

local ast = require("__the418_kb__/scripts/markup/parser/ast")
local constants = require("__the418_kb__/constants")
local topic_body = {}

--- @param Ast AST
--- @return LuaGuiElement
function topic_body.from_ast(Ast)
  local blocks = {}

  for _, block in pairs(Ast) do
    if block.kind == ast.KIND.Paragraph then
      table.insert(blocks, topic_body.paragraph(block --[[@as Paragraph]]))
    elseif block.kind == ast.KIND.Heading then
      table.insert(blocks, topic_body.heading(block --[[@as Heading]]))
    end
  end

  return {
    type = "scroll-pane",
    style = "naked_scroll_pane",
    style_mods = {
      width = 940,
      padding = 20,
      extra_padding_when_activated = 0,
      vertically_stretchable = "on",
    },
    table.unpack(blocks),
  }
end

--- @param paragraph Paragraph
--- @return LuaGuiElement
function topic_body.paragraph(paragraph)
  return {
    type = "flow",
    direction = "horizontal",
    style_mods = {
      horizontal_spacing = 0,
    },
    table.unpack(topic_body.inline_children(paragraph.children)),
  }
end

--- @param heading Heading
--- @return LuaGuiElement
function topic_body.heading(heading)
  local heading_label_font = "heading-" .. heading.level
  return {
    type = "flow",
    direction = "horizontal",
    style_mods = {
      horizontal_spacing = 0,
    },
    table.unpack(
      topic_body.inline_children(
        heading.children,
        { font = heading_label_font, font_color = constants.colors.Yellow }
      )
    ),
  }
end

--- @param children InlineContent[]
--- @param style_mods table<string, any>?
--- @return LuaGuiElement[]
function topic_body.inline_children(children, style_mods)
  local result = {}

  for _, content in pairs(children) do
    for _, block in pairs(topic_body.inline_content(content, style_mods or {})) do
      table.insert(result, block)
    end
  end

  return result
end

--- @param content InlineContent
--- @param style_mods table<string, any>
--- @private
--- @return LuaGuiElement[]
function topic_body.inline_content(content, style_mods)
  if content.kind == ast.KIND.Text then
    return {
      {
        type = "label",
        caption = content.text,
        style_mods = table.deep_merge({ {
          single_line = false,
        }, style_mods }),
      },
    }
  elseif content.kind == ast.KIND.EmphasisedText then
    if content.emphasis == "BOLD" then
      return topic_body.inline_children(
        content.children,
        table.deep_merge({ { font = "default-semibold" }, style_mods })
      )
    else
      error("Invalid text emphasis: " .. content.emphasis)
    end
  elseif content.kind == ast.KIND.SoftBreak then
    return {
      {
        type = "label",
        caption = " ",
      },
    }
  else
    -- not implemented
    return {}
  end
end

return topic_body
