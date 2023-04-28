local templates = {}

--- @class TopicsGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field topic_navigation LuaGuiElement
--- @field current_topic_contents LuaGuiElement

--- @return TopicsGuiRefs
function templates.render()
  return {
    {
      type = "frame",
      name = "the418_kb__topics_window",
      style_mods = { height = 800 },
      direction = "vertical",
      ref = { "window" },
      visible = false,
      actions = {
        on_closed = { gui = "topics", action = "close" },
      },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        style_mods = {
          horizontal_spacing = 8,
        },
        ref = { "titlebar_flow" },
        {
          type = "label",
          style = "frame_title",
          caption = { "gui.the418-kb--main-title" },
          ignored_by_interaction = true,
        },
        {
          type = "empty-widget",
          style = "flib_titlebar_drag_handle",
          ignored_by_interaction = true,
        },
        -- {
        --   type = "sprite-button",
        --   tooltip = { "gui.flib-keep-open" },
        --   ref = { "pin_button" },
        --   style = "frame_action_button",
        --   sprite = "flib_pin_white",
        --   hovered_sprite = "flib_pin_black",
        --   clicked_sprite = "flib_pin_black",
        --   actions = {
        --     on_click = { gui = "topics", action = "pin" },
        --   },
        -- },
        {
          type = "sprite-button",
          tooltip = { "gui.close" },
          style = "frame_action_button",
          sprite = "utility/close_white",
          hovered_sprite = "utility/close_black",
          clicked_sprite = "utility/close_black",
          actions = {
            on_click = { gui = "topics", action = "close" },
          },
        },
      },
      {
        type = "flow",
        style = "the418_kb__main_flow",
        direction = "horizontal",
        {
          type = "frame",
          style = "inside_deep_frame",
          direction = "vertical",
          style_mods = {
            width = 250,
            vertically_stretchable = "stretch_and_expand",
          },
          {
            type = "frame",
            style = "subheader_frame",
            direction = "horizontal",
            style_mods = {
              horizontally_stretchable = "stretch_and_expand",
              left_padding = 8,
              right_padding = 8,
              top_padding = 7,
            },
            {
              type = "label",
              caption = { "gui.the418-kb--caption-topics" },
              style_mods = {
                font = "heading-2",
              },
            },
            {
              type = "empty-widget",
              style = "flib_horizontal_pusher",
            },
            {
              type = "label",
              style = "the418_kb__label_button",
              caption = { "", "[", { "gui.the418-kb--add-topic" }, "]" },
              actions = {
                on_click = { gui = "topics", action = "add_topic" },
              },
            },
          },
          {
            type = "scroll-pane",
            style = "the418_kb__menu_scroll_pane",
            direction = "vertical",
            vertical_scroll_policy = "auto",
            ref = { "topic_navigation" },
          },
        },
        {
          type = "frame",
          style = "inside_shallow_frame",
          direction = "vertical",
          ref = { "current_topic_contents" },
        },
      },
    },
  }
end

--- @param Topic Topic
--- @param contents LuaGuiElement -- TODO
function templates.topic_contents(Topic, contents)
  local Lock = Topic:get_lock()
  game.print(serpent.line(contents))

  return {
    type = "frame",
    style = "the418_kb__content_frame",
    direction = "vertical",
    {
      type = "frame",
      style = "subheader_frame",
      direction = "horizontal",
      style_mods = {
        horizontally_stretchable = "stretch_and_expand",
        left_padding = 20,
        right_padding = 20,
        top_padding = 7,
      },
      {
        type = "label",
        style_mods = {
          font = "heading-2",
        },
        caption = Topic.title,
      },
      {
        type = "empty-widget",
        style = "flib_horizontal_pusher",
      },
      {
        type = "label",
        style = Lock and "the418_kb__label_button_disabled" or "the418_kb__label_button",
        caption = Lock
            and { "", "[", { "gui.the418-kb--topic-being-edited-by", Lock.player.name }, "]" }
          or { "", "[", { "gui.the418-kb--edit-topic" }, "]" },
        actions = {
          on_click = {
            gui = "topics",
            action = "edit_topic",
            topic_id = Topic.id,
          },
        },
      },
    },
    contents,
    -- {
    --   type = "scroll-pane",
    --   style = "naked_scroll_pane",
    --   style_mods = {
    --     width = 940,
    --     padding = 20,
    --     extra_padding_when_activated = 0,
    --     vertically_stretchable = "on",
    --   },
    --   {
    --     type = "label",
    --     caption = Topic.body,
    --     style_mods = {
    --       single_line = false,
    --     },
    --   },
    -- },
  }
end

function templates.no_topic_area()
  return {
    type = "frame",
    style = "the418_kb__content_frame",
    direction = "vertical",
  }
end

--- @param id number
--- @param caption string
--- @param level number
--- @param is_selected boolean
function templates.topic_button(id, caption, level, is_selected)
  return {
    type = "button",
    style = "the418_kb__menu_button"
      .. (level == 1 and "_primary" or "")
      .. (is_selected and "_selected" or ""),
    caption = caption,
    style_mods = {
      left_padding = level * 8,
    },
    actions = {
      on_click = { gui = "topics", action = "select", topic_id = id },
    },
  }
end

return templates
