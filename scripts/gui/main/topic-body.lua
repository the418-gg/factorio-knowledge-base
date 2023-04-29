local table = require("__flib__/table")

local ast = require("__the418_kb__/markup/parser/ast")
local constants = require("__the418_kb__/constants")

local topic_body = {}

--- @param Ast AST
--- @return LuaGuiElement
function topic_body.from_ast(Ast)
  local blocks = {}

  for _, block in pairs(Ast) do
    table.insert(blocks, topic_body.block(block))
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

--- @param block Block
--- @return LuaGuiElement
function topic_body.block(block)
  if block.kind == ast.KIND.Paragraph then
    return topic_body.paragraph(block --[[@as Paragraph]])
  elseif block.kind == ast.KIND.Heading then
    return topic_body.heading(block --[[@as Heading]])
  elseif block.kind == ast.KIND.List then
    return topic_body.list(block --[[@as List]])
  else
    -- TODO
    return {}
  end
end

--- @param paragraph Paragraph
--- @return LuaGuiElement
function topic_body.paragraph(paragraph)
  return {
    type = "flow",
    direction = "vertical",
    style_mods = {
      vertical_spacing = 0,
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
    direction = "vertical",
    style_mods = {
      vertical_spacing = 0,
    },
    table.unpack(
      topic_body.inline_children(
        heading.children,
        { font = heading_label_font, font_color = constants.colors.Yellow }
      )
    ),
  }
end

--- @param list List
--- @return LuaGuiElement
function topic_body.list(list)
  local items = {} --- @type LuaGuiElement[]

  local style_mods = {
    left_padding = (list.level - 1) * 6,
  }

  for _, item in pairs(list.items) do
    if item.kind == ast.KIND.List then
      table.insert(items, {
        type = "flow",
        direction = "horizontal",
        style_mods = style_mods,
        topic_body.list(item --[[@as List]]),
      })
    else
      table.insert(items, topic_body.list_item(list.list_type, item --[[@as ListItem]], list.level))
    end
  end

  return {
    type = "flow",
    direction = "vertical",
    style_mods = {
      vertical_spacing = 0,
    },
    table.unpack(items),
  }
end

--- @param list_type ListType
--- @param list_item ListItem
--- @param level uint
--- @return LuaGuiElement
function topic_body.list_item(list_type, list_item, level)
  local marker = list_type == "ORDERED" and tostring(list_item.order) .. "." or "•"

  return {
    type = "flow",
    direction = "horizontal",
    style_mods = {
      left_padding = (level - 1) * 6,
    },
    {
      type = "label",
      caption = marker,
    },
    topic_body.block(list_item.content),
  }
end

--- @param children InlineContent[]
--- @param style_mods table<string, any>?
--- @return LuaGuiElement
function topic_body.inline_children(children, style_mods)
  local lines = {}
  local line_contents = {}

  for i, content in pairs(children) do
    for _, block in pairs(topic_body.inline_content(content, style_mods or {})) do
      table.insert(line_contents, block)
    end
    if content.kind == ast.KIND.LineBreak or i == #children then
      table.insert(lines, {
        type = "flow",
        direction = "horizontal",
        style_mods = {
          horizontal_spacing = 0,
        },
        table.unpack(line_contents),
      })
    end
  end

  return lines
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
  elseif content.kind == ast.KIND.LineBreak then
    return {}
  else
    -- not implemented
    return {}
  end
end

return topic_body
