require 'parslet'

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

    rule(:task_desc)       { (match['#\n'].absent? >> any).repeat.as(:desc) }
    rule(:time_frame_desc) { (match['(\n'].absent? >> any).repeat.as(:desc) }
    # rule(:task_desc)       { (str(' #').absent? >> match['^\n']).repeat.as(:desc) }
    # rule(:time_frame_desc) { (str(' (').absent? >> match['^\n']).repeat.as(:desc) }
    # rule(:task_desc)       { (str("\n").absent? >> str(' #').absent? >> any).repeat.as(:desc) }
    # rule(:time_frame_desc) { (str("\n").absent? >> str(' (').absent? >> any).repeat.as(:desc) }

    rule(:tag)             { str('#') >> match['^\s'].repeat.as(:tag) >> space? }

    rule(:duration) do
      # ✔ 9:20
      # ✔ 9:20–10:00
      # ✔ started at 9:20 (this is not the same as just 9:20)
      # ✖ 9-10
      #   There was an issue with parsing that compared to 9 as duration.
      (hour_strict.as(:start_time) >> (time_delimiter >> hour_strict.as(:end_time)).maybe) | str('started at') >> hour_strict.as(:start_time)
    end

    rule(:task_time_info) do
      str('[') >> (duration | integer.as(:duration)) >> str(']') >> space
    end

    rule(:metadata) { (str("\n").absent? >> any).repeat.as(:line) }

    rule(:task_body) { indent >> task_time_info.maybe >> task_desc >> tag.repeat }
    rule(:metadata_block) { (nl >> str('  ') >> metadata).repeat(0) }

    rule(:task) do
      (task_body >> metadata_block).as(:task) >> nl.maybe # replaced nl_or_eof to fix the hang.
      # IMPORTANT NOTE: nl.maybe is because the tag definition eats up \n's for unknown reason.
    end

    rule(:time_range) do
      hour.as(:start_time) >> space? >> time_delimiter >> space? >> hour.as(:end_time)
    end

    rule(:time_from) do
      (str('from') | str('after')) >> space >> hour.as(:start_time)
    end

    rule(:time_frame_header) do
      time_frame_desc >> (lparen >> (time_range | time_from) >> rparen).maybe >> nl # replaced nl_or_eof to fix the hang.
    end

    rule(:time_frame_with_tasks) { (time_frame_header >> task.repeat.as(:task_list)).as(:time_frame) } # ...
    rule(:time_frames_with_tasks) { time_frame_with_tasks.repeat(0) }

    root(:time_frames_with_tasks)
  end
end
