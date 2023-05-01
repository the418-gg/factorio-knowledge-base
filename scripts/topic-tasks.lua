local on_tick_n = require("__flib__/on-tick-n")
local markup = require("__the418_kb__/markup/markup")

local constants = require("__the418_kb__/constants")
local player_gui = require("__the418_kb__/scripts/player-gui")

local topic_tasks = {}

--- @class ParseTopicBodyTask
--- @field type "parse_topic_body"
--- @field topic Topic
--- @field markup_data ParseTask

--- @param Topic Topic
function topic_tasks.add(Topic)
  --- @type ParseTopicBodyTask
  local task =
    { type = "parse_topic_body", topic = Topic, markup_data = markup.tasks.create(Topic.body) }
  on_tick_n.add(game.tick + constants.parse_topic_body_interval, task)
end

--- @param task ParseTopicBodyTask
function topic_tasks.handle(task)
  local updated_markup_data =
    markup.tasks.perform(task.markup_data, constants.parse_topic_body_blocks_per_task)

  if updated_markup_data.done then
    task.topic:set_body_ast(updated_markup_data.ast)
    player_gui.update_all_topics()
  else
    on_tick_n.add(game.tick + constants.parse_topic_body_interval, {
      type = "parse_topic_body",
      topic = task.topic,
      markup_data = updated_markup_data,
    })
  end
end

return topic_tasks
