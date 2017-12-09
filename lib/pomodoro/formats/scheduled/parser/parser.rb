require 'parslet'
require 'pomodoro/formats/scheduled'

module Pomodoro::Formats::Scheduled
  # @api private
  class Parser < Parslet::Parser
    rule(:header) {
      # match['^\n'].repeat # This makes it hang!
      (str("\n").absent? >> any).repeat(1).as(:header) >> str("\n")
    }

    rule(:task) {
      str('- ') >> match['^\n'].repeat.as(:task) >> str("\n").repeat
    }

    rule(:task_group) {
      (header >> task.repeat.as(:task_list)).as(:task_group)
    }

    rule(:task_groups) {
      task_group.repeat(0)
    }

    root(:task_groups)
  end
end
