local on_tick_n = require("__flib__/on-tick-n")
local markup = require("__the418_kb__/markup/markup")

local migrations = require("__the418_kb__/scripts/migrations")

on_tick_n.init()

for _, topic in pairs(global.topics) do
  topic.body_ast = markup.parse(topic.body)
end

migrations.generic()
