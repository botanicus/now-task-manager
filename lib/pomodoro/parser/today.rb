require 'parslet'

# .parse(input, reporter: Parslet::ErrorReporter::Deepest.new)
module Pomodoro
  class TodayParser < Parslet::Parser
    # Primitives.
    rule(:integer)         { match['0-9'].repeat(1) }

    rule(:nl)              { str("\n").repeat(1) }
    rule(:nl_or_eof)       { any.absent? | nl.maybe }

    rule(:space)           { match('\s').repeat(1) }
    rule(:space?)          { space.maybe }

    rule(:lparen)          { str('(') }
    rule(:rparen)          { str(')') }
    rule(:time_delimiter)  { match['-–'] }
    rule(:colon)           { str(':') }

    rule(:hour)            { (integer.repeat >> (colon >> integer).maybe).as(:hour) }
    rule(:hour_strict)     { (integer.repeat >> colon >> integer).as(:hour) }
    rule(:indent)          { match['-✓✔✕✖✗✘'].as(:indent).repeat(1, 1) >> space }
    rule(:task_desc)       { (match['\n#'].absent? >> any).repeat.as(:desc) }
    rule(:time_frame_desc) { (match['(\n'].absent? >> any).repeat.as(:desc) }

    rule(:tag)             { str('#') >> match['^\s'].repeat.as(:tag) >> space? }

    rule(:duration) do
      # ✔ 9:20
      # ✔ 9:20–10:00
      # ✖ 9-10
      #   There was an issue with parsing that compared to 9 as duration.
      hour_strict.as(:start_time) >> (time_delimiter >> hour_strict.as(:end_time)).maybe
    end

    rule(:task_time_info) do
      str('[') >> (duration | integer.as(:duration)) >> str(']') >> space
    end

    rule(:metadata) { (str("\n").absent? >> any).repeat.as(:line) }

    rule(:task_body) { indent >> task_time_info.maybe >> task_desc >> tag.repeat }

    rule(:task) do
      (task_body >> (nl >> str('  ') >> metadata).repeat(0)).as(:task) >> nl_or_eof
    end

    rule(:time_range) do
      hour.as(:start_time) >> space? >> time_delimiter >> space? >> hour.as(:end_time)
    end

    rule(:time_frame) do
      time_frame_desc >> (lparen >> time_range >> rparen).maybe >> nl_or_eof
    end

    rule(:time_frame_with_tasks) { time_frame >> task.repeat.as(:task_list) } # ...
    # >> str("\n") \n\n is required.
    rule(:time_frames_with_tasks) { time_frame_with_tasks.repeat(0) }

    root(:time_frame_with_tasks)
  end
end
