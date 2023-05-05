local markup = require("__the418_kb__/markup/markup")
local migrations = require("__the418_kb__/scripts/migrations")

for _, topic in pairs(global.topics) do
  topic.body_ast = markup.parse(topic.body)
end

migrations.generic()
