-- Hack to avoid circular dependencies for now, will rewrite
local main_gui = require(
  "__the418_kb__/scripts/gui/main/gui"
)
local edit_topic_gui = require(
  "__the418_kb__/scripts/gui/edit-topic/gui"
)

local guis = {
  main = main_gui,
  edit_topic = edit_topic_gui,
}

return guis
