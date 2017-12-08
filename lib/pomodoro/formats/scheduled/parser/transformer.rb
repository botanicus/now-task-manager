require 'parslet'
require 'pomodoro/formats/scheduled'

module Pomodoro::Formats::Scheduled
  # @api private
  class Transformer < Parslet::Transform
    rule(task: simple(:task)) { task.to_s }
    rule(task_group_header: simple(:header)) { header.to_s } # Doesn't work. Has multiple keys by the way.

    rule(task_group: subtree(:task_group)) {
      TaskGroup.new(name: task_group[:task_group_header].to_s, tasks: task_group[:task_list])
    }
  end
end
