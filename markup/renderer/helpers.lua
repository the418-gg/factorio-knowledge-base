local helpers = {}

--- @param icon string
--- @return LuaGuiElement
function helpers.make_sprite(icon)
  return {
    type = "sprite",
    sprite = icon,
    style_mods = {
      padding = 2,
      width = 32,
      height = 32,
      stretch_image_to_widget_size = true,
    },
  }
end

--- @param rows LuaGuiElement[]
--- @return LuaGuiElement
function helpers.vertical_icon_flow(rows)
  return {
    type = "flow",
    direction = "vertical",
    ignored_by_interaction = true,
    style_mods = {
      width = 64,
      height = 64,
      vertical_spacing = 0,
      padding = 0,
      vertical_align = "center",
    },
    table.unpack(rows),
  }
end

--- @param icons LuaGuiElement[]
--- @return LuaGuiElement
function helpers.horizontal_icon_row(icons)
  return {
    type = "flow",
    direction = "horizontal",
    style_mods = {
      width = 64,
      horizontal_spacing = 0,
      padding = 0,
      horizontal_align = "center",
    },
    table.unpack(icons),
  }
end

--- @param type "blueprint" | "blueprint_book" | "deconstruction_planner" | "upgrade_planner"
--- @param data table
--- @return LuaGuiElement
function helpers.make_special_item_sprite_icons(type, data)
  local icons = helpers.get_special_item_icons(type, data)

  if #icons == 0 then
    return {}
  end

  local icons_top = {}
  local icons_bottom = {}

  for i, icon_data in pairs(helpers.get_special_item_icons(type, data)) do
    if i > 4 then
      break
    end

    table.insert(i > 2 and icons_bottom or icons_top, helpers.make_sprite(icon_data))
  end

  return helpers.vertical_icon_flow({
    helpers.horizontal_icon_row(icons_top),
    #icons_bottom > 0 and helpers.horizontal_icon_row(icons_bottom) or nil,
  })
end

-- TODO take indices into account maybe?
--- @param type "blueprint" | "blueprint_book" | "deconstruction_planner" | "upgrade_planner"
--- @param data table
--- @return string[]
function helpers.get_special_item_icons(type, data)
  local icons = {}

  if type == "blueprint" then
    for _, icon_data in pairs(data.blueprint.icons) do
      table.insert(icons, icon_data.signal.type .. "/" .. icon_data.signal.name)
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
      table.insert(icons, mapper.to.type .. "/" .. mapper.to.name)
    end
  end

  return icons
end

return helpers
