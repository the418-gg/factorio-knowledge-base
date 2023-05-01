local constants = {}

constants.topic_lock_update_interval = 600 -- approx. 10 seconds (when UPS is 60)
constants.parse_topic_body_interval = 15 -- ticks
constants.parse_topic_body_blocks_per_task = 10

constants.colors = {
  Yellow = { 255, 230, 192 },
  Orange = { 255, 128, 0 },
}

return constants
