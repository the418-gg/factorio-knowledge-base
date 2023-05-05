local constants = require("__the418_kb__/constants")

data:extend({
  {
    type = "custom-input",
    name = "the418-kb--toggle-interface",
    key_sequence = "CONTROL + I",
    order = "a",
  },
  {
    type = "custom-input",
    name = "the418-kb--linked-confirm-gui",
    key_sequence = "",
    linked_game_control = "confirm-gui",
  },
  {
    type = "shortcut",
    name = "the418-kb--toggle-interface",
    icon = { filename = "__the418_kb__/graphics/kb-dark-x32.png", size = 32, mipmap_count = 2 },
    small_icon = {
      filename = "__the418_kb__/graphics/kb-dark-x24.png",
      size = 24,
      mipmap_count = 2,
    },
    disabled_icon = {
      filename = "__the418_kb__/graphics/kb-light-x32.png",
      size = 32,
      mipmap_count = 2,
    },
    disabled_small_icon = {
      filename = "__the418_kb__/graphics/kb-light-x24.png",
      size = 24,
      mipmap_count = 2,
    },
    toggleable = true,
    associated_control_input = "the418-kb--toggle-interface",
    action = "lua",
  },
})

local styles = data.raw["gui-style"].default

styles.the418_kb__main_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 8,
}

styles.the418_kb__menu_button = {
  type = "button_style",
  font = "default-listbox",
  horizontal_align = "left",
  horizontally_stretchable = "on",
  horizontally_squashable = "on",
  default_font_color = { 227, 227, 227 },
  hovered_font_color = { 0, 0, 0 },
  selected_clicked_font_color = { 0.97, 0.54, 0.15 },
  selected_font_color = { 0.97, 0.54, 0.15 },
  selected_hovered_font_color = { 0.97, 0.54, 0.15 },
  default_graphical_set = {
    corner_size = 8,
    position = { 208, 17 },
  },
  clicked_graphical_set = {
    corner_size = 8,
    position = { 352, 17 },
  },
  hovered_graphical_set = {
    base = {
      corner_size = 8,
      position = { 34, 17 },
    },
  },
  disabled_graphical_set = {
    corner_size = 8,
    position = { 17, 17 },
  },
}

styles.the418_kb__menu_button_selected = {
  type = "button_style",
  parent = "the418_kb__menu_button",
  default_font_color = { 0, 0, 0 },
  hovered_font_color = { 0, 0, 0 },
  selected_clicked_font_color = { 0, 0, 0 },
  selected_font_color = { 0, 0, 0 },
  selected_hovered_font_color = { 0, 0, 0 },
  default_graphical_set = {
    corner_size = 8,
    position = { 54, 17 },
  },
  hovered_graphical_set = {
    corner_size = 8,
    position = { 54, 17 },
  },
}

styles.the418_kb__menu_scroll_pane = {
  type = "scroll_pane_style",
  parent = "list_box_scroll_pane",
  horizontally_stretchable = "stretch_and_expand",
  vertically_stretchable = "stretch_and_expand",
  dont_force_clipping_rect_for_contents = true,
  padding = 0,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 2,
  },
}

styles.the418_kb__menu_button_primary = {
  type = "button_style",
  parent = "the418_kb__menu_button",
  font = "default-bold",
  default_font_color = { 255, 230, 192 },
}

styles.the418_kb__menu_button_primary_selected = {
  type = "button_style",
  parent = "the418_kb__menu_button_selected",
  font = "default-bold",
}

styles.the418_kb__content_frame = {
  type = "frame_style",
  parent = "inside_shallow_frame",
  width = 960,
  horizontally_stretchable = "on",
  vertically_stretchable = "on",
  vertical_align = "center",
}

styles.the418_kb__red_dialog_button = {
  type = "button_style",
  parent = "dialog_button",
  default_graphical_set = styles.red_button.default_graphical_set,
  hovered_graphical_set = styles.red_button.hovered_graphical_set,
  clicked_graphical_set = styles.red_button.clicked_graphical_set,
}

styles.the418_kb__label_button = {
  type = "label_style",
  font = "default-semibold",
  font_color = { 128, 206, 240 },
  hovered_font_color = { 154, 250, 255 },
}

styles.the418_kb__label_button_disabled = {
  type = "label_style",
  parent = "the418_kb__label_button",
  font_color = { 128, 128, 128 },
  hovered_font_color = { 128, 128, 128 },
}

styles.the418_kb__edit_topic_textbox = {
  type = "textbox_style",
  height = 800,
  width = 800,
  rich_text_setting = "disabled",
}

styles.the418_kb__markup__inline__text = {
  type = "label_style",
  single_line = false,
  rich_text_setting = "disabled",
}

styles.the418_kb__markup__inline__code = {
  type = "label_style",
  parent = "the418_kb__markup__inline__text",
  font_color = constants.colors.Orange,
}

styles.the418_kb__markup__code_block = {
  type = "textbox_style",
  horizontally_stretchable = "on",
  rich_text_setting = "disabled",
}
