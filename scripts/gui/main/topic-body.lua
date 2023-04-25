local ast = require("__the418_kb__/scripts/markup/parser/ast")
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
    table.unpack(topic_body.inline_children(paragraph.children)),
  }
end

--- @param heading Heading
--- @return LuaGuiElement
function topic_body.heading(heading)
  local heading_label_style = "heading_" .. heading.level .. "_label"
  return {
    type = "flow",
    direction = "horizontal",
    table.unpack(
      topic_body.inline_children(heading.children, { [ast.KIND.Text] = heading_label_style })
    ),
  }
end

--- @param children InlineContent[]
--- @param style_overrides table<string, string>?
--- @return LuaGuiElement[]
function topic_body.inline_children(children, style_overrides)
  local result = {}

  for _, content in pairs(children) do
    table.insert(result, topic_body.inline_content(content, style_overrides or {}))
  end

  return result
end

--- @param content InlineContent
--- @param style_overrides table<string, string>
--- @private
--- @return LuaGuiElement
function topic_body.inline_content(content, style_overrides)
  if content.kind == ast.KIND.Text then
    return {
      type = "label",
      style = style_overrides.TEXT,
      caption = content.text,
      style_mods = {
        single_line = false,
      },
    }
  else
    -- not implemented
    return {}
  end
end

return topic_body
