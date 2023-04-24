local templates = {}

--- @class ConfirmDeleteTopicGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field footer_flow LuaGuiElement

--- @param Topic Topic
function templates.render(Topic)
  return {
    {
      type = "frame",
      name = "the418_kb__confirm_delete_topic_window",
      style_mods = { width = 448 },
      direction = "vertical",
      ref = { "window" },
      actions = {
        on_closed = { gui = "confirm_delete_topic", action = "close" },
      },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar_flow" },
        {
          type = "label",
          style = "frame_title",
          caption = { "gui.the418-kb--caption-confirm-delete-topic" },
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
          {
            type = "label",
            caption = { "gui.the418-kb--confirm-delete-topic-are-you-sure", Topic.title },
          },
          #Topic.child_ids > 0 and {
            type = "label",
            style = "orange_label",
            caption = { "gui.the418-kb--confirm-delete-topic-will-delete-children" },
          } or {},
        },
      },
      {
        type = "flow",
        style = "dialog_buttons_horizontal_flow",
        ref = { "footer_flow" },
        {
          type = "button",
          style = "back_button",
          caption = { "gui.cancel" },
          actions = {
            on_click = { gui = "confirm_delete_topic", action = "close" },
          },
        },
        {
          type = "empty-widget",
          style = "flib_horizontal_pusher",
        },
        {
          type = "button",
          style = "red_confirm_button",
          caption = { "gui.delete" },
          actions = {
            on_click = { gui = "confirm_delete_topic", action = "confirm" },
          },
        },
      },
    },
  }
end

return templates
