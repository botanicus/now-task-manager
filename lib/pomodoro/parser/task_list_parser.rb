require 'parslet'

module Pomodoro
  class TaskListParser < Parslet::Parser
    rule(:task_group_header) {
      # match['^\n'].repeat # This makes it hang!
      (str("\n").absent? >> any).repeat(1).as(:task_group_header) >> str("\n")
    }

    rule(:task) {
      str('- ') >> match['^\n'].repeat.as(:task) >> str("\n").repeat
    }

    rule(:task_group) {
      (task_group_header >> task.repeat.as(:task_list)).as(:task_group)
    }

    rule(:task_groups) {
      task_group.repeat(0)
    }

    root(:task_groups)
  end
end
