# frozen_string_literal: true

require 'parslet'
require 'pomodoro/formats/scheduled'

module Pomodoro::Formats::Scheduled
  # @api private
  class Parser < Parslet::Parser
    rule(:hour_strict) {
      (match['\d'].repeat(1) >> str(':') >> match['\d'].repeat(2, 2)).as(:hour)
    }

    rule(:start_time) {
      str('[') >> hour_strict.as(:start_time) >> str(']') >> str(' ').maybe
    }

    rule(:time_frame) {
      # TODO: (hour_strict.absent? >> match['^\]\n'] >> any)
      str('[') >> match['\w '].repeat.as(:str) >> str(']') >> str(' ').maybe
    }

    rule(:header) {
      # match['^\n'].repeat # This makes it hang!
      (str("\n").absent? >> any).repeat(1).as(:str) >> str("\n")
    }

    rule(:task_body) do
      (match['#\n'].absent? >> any).repeat.as(:str)
    end

    rule(:tag) do
      str('#') >> match['^\s'].repeat.as(:str) >> str(' ').maybe
    end

    rule(:task) {
      str('- ') >> (time_frame.as(:time_frame).maybe >> start_time.maybe >> task_body.as(:body) >> tag.as(:tag).repeat.as(:tags).maybe).as(:task) >> str("\n").repeat
    }

    rule(:task_group) {
      (header.as(:header) >> task.repeat.as(:tasks)).as(:task_group)
    }

    rule(:task_groups) {
      task_group.repeat(0)
    }

    root(:task_groups)
  end
end
