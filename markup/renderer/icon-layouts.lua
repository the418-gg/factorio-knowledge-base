--- @alias IconLayout table<"icon" | "vertical_flow" | "horizontal_flow", table>

--- @type table<_, IconLayout>
local icon_layouts = {
  default = {
    icon = {},
    vertical_flow = {},
    horizontal_flow = {},
  },
  single_icon = {
    icon = {
      width = 48,
      height = 48,
    },
    vertical_flow = {
      horizontal_align = "center",
    },
    horizontal_flow = {
      horizontal_align = "center",
    },
  },
  blueprint_book = {
    icon = {
      width = 22,
      height = 22,
    },
    vertical_flow = {
      width = 44,
      height = 44,
      top_margin = -5,
      left_margin = 1,
      horizontal_align = "center",
    },
    horizontal_flow = {
      width = 44,
    },
  },
  blueprint_book_single_icon = {
    icon = {
      width = 38,
      height = 38,
    },
    vertical_flow = {
      width = 44,
      height = 44,
      top_margin = -5,
      left_margin = 6,
      horizontal_align = "center",
    },
    horizontal_flow = {
      width = 44,
    },
  },
}

return icon_layouts
