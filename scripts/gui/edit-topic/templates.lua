local util = require("__the418_kb__/scripts/util")

local templates = {}

--- @class EditTopicGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field footer_flow LuaGuiElement
--- @field title_textfield LuaGuiElement
--- @field body_textfield LuaGuiElement
--- @field parent_dropdown LuaGuiElement

--- @param topic Topic?
--- @param available_parents Topic[]
function templates.render(topic, available_parents)
  local title_caption = topic and { "gui.the418-kb--caption-edit-topic" } or
      { "gui.the418-kb--caption-new-topic" }
  local parents = { { "gui.the418-kb--parent-root" } }
  local parent_selection_index = 1

  for _, parent in ipairs(available_parents) do
    table.insert(parents, parent.title)

    if topic and util.has_value(parent.child_ids, topic.id) then
      parent_selection_index = #parents
    end
  end

  return {
    {
      type = "frame",
      name = "the418_kb__edit_topic_window",
      style_mods = { width = 448 },
      direction = "vertical",
      ref = { "window" },
      actions = {
        on_closed = { gui = "edit_topic", action = "close" },
      },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar_flow" },
        actions = {
          on_click = { gui = "edit_topic", transform = "handle_titlebar_click" },
        },
        {
          type = "label",
          style = "frame_title",
          caption = title_caption,
          ignored_by_interaction = true,
        },
        {
          type = "empty-widget",
          style = "flib_dialog_titlebar_drag_handle",
          ignored_by_interaction = true,
        },
      },
      {
        type = "frame",
        style = "inside_shallow_frame",
        direction = "vertical",
        {
          type = "flow",
          style_mods = { padding = 12, vertical_spacing = 8 },
          direction = "vertical",
          { type = "label", caption = { "gui.the418-kb--title" } },
          {
            type = "textfield",
            style = "flib_widthless_textfield",
            style_mods = { horizontally_stretchable = true },
            text = topic and topic.title or "",
            ref = { "title_textfield" },
            actions = {
              on_confirmed = { gui = "edit_topic", action = "confirm" },
            },
          },
          { type = "label", caption = { "gui.the418-kb--body" } },
          {
            type = "text-box",
            style_mods = { height = 200, width = 400 },
            text = topic and topic.body or "",
            elem_mods = { word_wrap = true },
            ref = { "body_textfield" },
            actions = {
              on_confirmed = { gui = "edit_topic", action = "confirm" },
            },
          },
          {
            type = "flow",
            style_mods = { vertical_align = "center" },
            { type = "label",        caption = { "gui.the418-kb--parent" } },
            { type = "empty-widget", style = "flib_horizontal_pusher" },
            {
              type = "drop-down",
              items = parents,
              selected_index = parent_selection_index,
              enabled = #parents > 1,
              ref = { "parent_dropdown" },
            },
          },
        },
      },
      {
        type = "flow",
        style = "dialog_buttons_horizontal_flow",
        actions = {
          on_click = { gui = "edit_topic", transform = "handle_titlebar_click" } },
        ref = { "footer_flow" },
        {
          type = "button",
          style = "back_button",
          caption = { "gui.cancel" },
          actions = {
            on_click = { gui = "edit_topic", action = "close" },
          },
        },
        {
          type = "empty-widget",
          style = "flib_dialog_footer_drag_handle",
          ignored_by_interaction = true,
        },
        topic and {
          type = "button",
          style = "the418_kb__red_dialog_button",
          caption = { "gui.delete" },
          actions = {
            on_click = { gui = "edit_topic", action = "delete" },
          },
        } or {},
        topic and {
          type = "empty-widget",
          style = "flib_dialog_footer_drag_handle",
          ignored_by_interaction = true,
        } or {},
        {
          type = "button",
          style = "confirm_button",
          caption = { "gui.confirm" },
          actions = {
            on_click = { gui = "edit_topic", action = "confirm" },
          },
        },
      },
    },
  }
end

return templates
