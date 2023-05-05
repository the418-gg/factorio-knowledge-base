local table = require("__flib__/table")

local ast = require("__the418_kb__/markup/parser/ast")
local helpers = require("__the418_kb__/markup/renderer/helpers")
local constants = require("__the418_kb__/constants")

local renderer = {}

local blueprint_sprite_map = {
  blueprint = "item/blueprint",
  ["blueprint_book"] = "item/blueprint-book",
  ["deconstruction_planner"] = "item/deconstruction-planner",
  ["upgrade_planner"] = "item/upgrade-planner",
}

--- @param Ast AST
--- @return LuaGuiElement
function renderer.from_ast(Ast)
  local blocks = {}

  for _, block in pairs(Ast) do
    table.insert(blocks, renderer.block(block))
  end

  return {
    type = "flow",
    direction = "vertical",
    style_mods = {
      vertical_spacing = 16,
      horizontally_stretchable = "on",
    },
    table.unpack(blocks),
  }
end

--- @private
--- @param block Block
--- @return LuaGuiElement
function renderer.block(block)
  if block.kind == ast.KIND.Paragraph then
    return renderer.paragraph(block --[[@as Paragraph]])
  elseif block.kind == ast.KIND.Heading then
    return renderer.heading(block --[[@as Heading]])
  elseif block.kind == ast.KIND.List then
    return renderer.list(block --[[@as List]])
  elseif block.kind == ast.KIND.HorizontalRule then
    return renderer.horizontal_rule()
  elseif block.kind == ast.KIND.CodeBlock then
    return renderer.code_block(block --[[@as CodeBlock]])
  elseif block.kind == ast.KIND.BlueprintBlock then
    return renderer.blueprint_block(block --[[@as BlueprintBlock]])
  else
    -- TODO
    return {}
  end
end

--- @private
--- @param paragraph Paragraph
--- @return LuaGuiElement
function renderer.paragraph(paragraph)
  return {
    type = "flow",
    direction = "vertical",
    style_mods = {
      vertical_spacing = 0,
    },
    table.unpack(renderer.inline_children(paragraph.children)),
  }
end

--- @private
--- @param heading Heading
--- @return LuaGuiElement
function renderer.heading(heading)
  local heading_label_font = "heading-" .. heading.level
  return {
    type = "flow",
    direction = "vertical",
    style_mods = {
      vertical_spacing = 0,
    },
    table.unpack(
      renderer.inline_children(
        heading.children,
        { font = heading_label_font, font_color = constants.colors.Yellow }
      )
    ),
  }
end

--- @private
--- @param list List
--- @return LuaGuiElement
function renderer.list(list)
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
        renderer.list(item --[[@as List]]),
      })
    else
      table.insert(items, renderer.list_item(list.list_type, item --[[@as ListItem]], list.level))
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

--- @private
--- @param list_type ListType
--- @param list_item ListItem
--- @param level uint
--- @return LuaGuiElement
function renderer.list_item(list_type, list_item, level)
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
    renderer.block(list_item.content),
  }
end

--- @private
--- @return LuaGuiElement
function renderer.horizontal_rule()
  return {
    type = "line",
    style = "inside_shallow_frame_with_padding_line",
    style_mods = {
      left_margin = 0,
      right_margin = 0,
    },
  }
end

--- @private
--- @param block CodeBlock
--- @return LuaGuiElement
function renderer.code_block(block)
  local max_width = 888
  local max_line_length_without_scroll = math.floor(max_width / 8) - 1
  local lines = 0
  local max_line_length = 0
  for line in string.gmatch(block.text, "[^\r^\n]+") do
    if max_line_length < #line then
      max_line_length = #line
    end
    lines = lines + 1
  end
  local base_height = lines * 20 + 8

  return {
    type = "text-box",
    style = "the418_kb__markup__code_block",
    text = block.text,
    elem_mods = {
      read_only = true,
    },
    style_mods = {
      height = max_line_length > max_line_length_without_scroll and base_height + 16 or base_height,
      maximal_width = max_width,
    },
  }
end

--- @private
--- @param block BlueprintBlock
--- @return LuaGuiElement
function renderer.blueprint_block(block)
  return {
    type = "flow",
    direction = "vertical",
    style_mods = {
      horizontal_align = "center",
      vertical_spacing = 4,
    },
    {
      type = "sprite-button",
      style = "inventory_slot",
      sprite = blueprint_sprite_map[block.type] or "item/blueprint",
      style_mods = {
        padding = 4,
        width = 80,
        height = 80,
      },
      tags = { ["the418_kb__markup__blueprint_string"] = block.value },
      helpers.make_special_item_sprite_icons(block.type, block.blueprint_data),
    },
    {
      type = "label",
      caption = block.caption or block.blueprint_data[block.type].label,
      style_mods = {
        width = 80,
        single_line = false,
        horizontal_align = "center",
        horizontally_squashable = true,
      },
    },
  }
end

--- @private
--- @param children InlineContent[]
--- @param style_mods table<string, any>?
--- @return LuaGuiElement
function renderer.inline_children(children, style_mods)
  local lines = {}
  local line_contents = {}

  for i, content in pairs(children) do
    for _, block in pairs(renderer.inline_content(content, style_mods or {})) do
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

      line_contents = {}
    end
  end

  return lines
end

--- @private
--- @param content InlineContent
--- @param style_mods table<string, any>
--- @private
--- @return LuaGuiElement[]
function renderer.inline_content(content, style_mods)
  if content.kind == ast.KIND.Text then
    return {
      {
        type = "label",
        style = "the418_kb__markup__inline__text",
        caption = content.text,
        style_mods = style_mods,
      },
    }
  elseif content.kind == ast.KIND.EmphasisedText then
    if content.emphasis == "BOLD" then
      return renderer.inline_children(
        content.children,
        table.deep_merge({ { font = "default-semibold" }, style_mods })
      )
    else
      error("Invalid text emphasis: " .. content.emphasis)
    end
  elseif content.kind == ast.KIND.CodeInline then
    return {
      {
        type = "label",
        style = "the418_kb__markup__inline__code",
        caption = content.text,
      },
    }
  elseif content.kind == ast.KIND.FactorioRichText then
    return {
      {
        type = "label",
        style = "the418_kb__markup__inline__text",
        caption = "[" .. content.key .. "=" .. content.value .. "]",
        style_mods = style_mods,
      },
    }
  elseif content.kind == ast.KIND.BlueprintInline then
    return {
      {
        type = "label",
        style = "the418_kb__markup__inline__text",
        style_mods = style_mods,
        caption = "[special-item=" .. content.value .. "]",
        tags = { ["the418_kb__markup__blueprint_string"] = content.value },
      },
    }
  elseif content.kind == ast.KIND.SoftBreak then
    return {
      {
        type = "label",
        caption = " ",
      },
    }
  elseif content.kind == ast.KIND.LineBreak then
    return { { type = "label" } }
  else
    -- not implemented
    return {}
  end
end

return renderer
