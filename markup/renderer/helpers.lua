local flib_table = require("__flib__/table")

local icon_layouts = require("__the418_kb__/markup/renderer/icon-layouts")

local helpers = {}

--- @param layout IconLayout
--- @param icon string
--- @return LuaGuiElement
function helpers.make_sprite(layout, icon)
  return {
    type = "sprite",
    sprite = icon,
    style_mods = flib_table.shallow_merge({
      {
        padding = 2,
        width = 32,
        height = 32,
        stretch_image_to_widget_size = true,
      },
      layout.icon,
    }),
  }
end

--- @param layout IconLayout
--- @param rows LuaGuiElement[]
--- @return LuaGuiElement
function helpers.vertical_icon_flow(layout, rows)
  return {
    type = "flow",
    direction = "vertical",
    style_mods = flib_table.shallow_merge({
      {
        width = 64,
        height = 64,
        vertical_spacing = 0,
        padding = 0,
        vertical_align = "center",
      },
      layout.vertical_flow,
    }),
    table.unpack(rows),
  }
end

--- @param layout IconLayout
--- @param icons LuaGuiElement[]
--- @return LuaGuiElement
function helpers.horizontal_icon_row(layout, icons)
  return {
    type = "flow",
    direction = "horizontal",
    style_mods = flib_table.shallow_merge({
      {
        width = 64,
        horizontal_spacing = 0,
        padding = 0,
      },
      layout.horizontal_flow,
    }),
    table.unpack(icons),
  }
end

--- @param type SpecialItemType
--- @param data table
--- @return LuaGuiElement
function helpers.make_special_item_sprite_icons(type, data)
  local icons = helpers.get_special_item_icons(type, data)
  local layout = icon_layouts.default
  if #icons == 0 then
    return {}
  elseif #icons == 1 then
    if type == "blueprint_book" then
      layout = icon_layouts.blueprint_book_single_icon
    else
      layout = icon_layouts.single_icon
    end
  elseif type == "blueprint_book" then
    layout = icon_layouts.blueprint_book
  end

  local icons_top = {}
  local icons_bottom = {}

  for i, icon_data in pairs(helpers.get_special_item_icons(type, data)) do
    if i > 4 then
      break
    end

    table.insert(i > 2 and icons_bottom or icons_top, helpers.make_sprite(layout, icon_data))
  end

  return {
    type = "flow",
    ignored_by_interaction = true,
    style_mods = {
      width = 64,
      height = 64,
      padding = 0,
      vertical_align = "center",
      horizontal_align = "center",
    },
    helpers.vertical_icon_flow(layout, {
      helpers.horizontal_icon_row(layout, icons_top),
      #icons_bottom > 0 and helpers.horizontal_icon_row(layout, icons_bottom) or nil,
    }),
  }
end

-- TODO take indices into account maybe?
--- @param type SpecialItemType
--- @param data table
--- @return string[]
function helpers.get_special_item_icons(type, data)
  local icons = {}

  if type == "blueprint" then
    for _, icon_data in pairs(data.blueprint.icons) do
      table.insert(icons, helpers.make_sprite_path(icon_data.signal.type, icon_data.signal.name))
    end
  elseif type == "blueprint_book" then
    for _, icon_data in pairs(data.blueprint_book.icons) do
      table.insert(icons, helpers.make_sprite_path(icon_data.signal.type, icon_data.signal.name))
    end
  elseif type == "deconstruction_planner" then
    local settings = data.deconstruction_planner.settings

    if settings.entity_filters then
      for _, entity_filter in pairs(settings.entity_filters) do
        table.insert(icons, "entity/" .. entity_filter.name)
      end
    end

    if settings.tile_filters then
      for _, tile_filter in pairs(settings.tile_filters) do
        table.insert(icons, "tile/" .. tile_filter.name)
      end
    end
  elseif type == "upgrade_planner" then
    for _, mapper in pairs(data.upgrade_planner.settings.mappers) do
      table.insert(icons, helpers.make_sprite_path(mapper.to.type, mapper.to.name))
    end
  end

  -- discard invalid sprite paths
  icons = flib_table.filter(icons, function(sprite_path)
    return game.is_valid_sprite_path(sprite_path)
  end)

  return icons
end

--- @param type string
--- @param name string
--- @return string
function helpers.make_sprite_path(type, name)
  local mapped_type = type == "virtual" and "virtual-signal" or type
  return mapped_type .. "/" .. name
end

--- @alias SpecialItemType "blueprint" | "blueprint_book" | "deconstruction_planner" | "upgrade_planner"

return helpers
