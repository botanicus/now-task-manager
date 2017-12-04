require 'parslet'

module Pomodoro
  class TodayParser < Parslet::Parser
    # Primitives.
    rule(:integer) { match['0-9'].repeat(1) }

    rule(:nl)      { str("\n").repeat(1) }
    rule(:nl?)     { nl.maybe }

    rule(:space)      { match('\s').repeat(1) }
    rule(:space?)     { space.maybe }

    rule(:lparen) { str('(') }
    rule(:rparen) { str(')') }
    rule(:time_delimiter)  { match['-–'] }
    rule(:colon)  { str(':') }

    rule(:hour) { integer >> colon >> integer }

    rule(:indent)  { match['-✓✔✕✖✗✘'].as(:indent).repeat(1, 1) >> space }
    rule(:desc) { match['^\n'].repeat(1) }
    # rule(:desc) { match('[^\n#]').repeat(1) }

    ###
    # rule(:word) { match['a-zA-Z'].repeat(1).as(:word) >> space? }
    # rule(:task)      { indent.as(:indent) >> time_info.maybe >> desc.as(:desc) >> tag.repeat.as(:tags) }
    rule(:task) { (indent >> desc.as(:desc)).as(:task) >> nl? }

    ###
    rule(:time_range) { hour.as(:start_time) >> space? >> time_delimiter >> space? >> hour.as(:end_time) }
    rule(:time_frame) { match['\w\d '].repeat.as(:desc) >> (lparen >> time_range >> rparen).maybe >> nl? }
    rule(:time_frame_with_tasks) { time_frame >> task.repeat.as(:task_list) } #  >> str("\n") \n\n is required.
    rule(:time_frames_with_tasks) { time_frame_with_tasks.repeat(0) }

    root(:time_frame_with_tasks)
  end
end
