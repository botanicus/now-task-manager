require 'parslet'
require 'pomodoro/formats/today'

module Pomodoro::Formats::Today
  class Parser < Parslet::Parser
    # Primitives.
    rule(:integer)         { match['0-9'].repeat(1) }

    rule(:nl)              { str("\n").repeat(1) }
    rule(:nl_or_eof)       { any.absent? | nl.maybe }

    rule(:space)           { str(' ').repeat(1) }
    rule(:space?)          { space.maybe }

    rule(:lparen)          { str('(') }
    rule(:rparen)          { str(')') }
    rule(:time_delimiter)  { match['-–'] | str('to') }
    rule(:colon)           { str(':') }

    rule(:hour)            { (integer.repeat >> (colon >> integer).maybe).as(:hour) }
    rule(:hour_strict)     { (integer.repeat >> colon >> integer).as(:hour) }
    rule(:indent)          { match['-✓✔✕✖✗✘'].repeat(1, 1).as(:str) >> space }

    rule(:task_desc)       { (match['#\n'].absent? >> any).repeat.as(:str) }
    rule(:time_frame_desc) { (match['(\n'].absent? >> any).repeat.as(:str) }
    # rule(:task_desc)       { (str(' #').absent? >> match['^\n']).repeat.as(:desc) }
    # rule(:time_frame_desc) { (str(' (').absent? >> match['^\n']).repeat.as(:desc) }
    # rule(:task_desc)       { (str("\n").absent? >> str(' #').absent? >> any).repeat.as(:desc) }
    # rule(:time_frame_desc) { (str("\n").absent? >> str(' (').absent? >> any).repeat.as(:desc) }

    rule(:tag)             { str('#') >> match['^\s'].repeat.as(:tag) >> space? }

    rule(:start_time_end_time) do
      # ✔ 9:20
      # ✔ 9:20–10:00
      # ✖ 9-10
      #   There was an issue with parsing that compared to 9 as duration.
      (hour_strict.as(:start_time) >> time_delimiter >> (hour_strict.as(:end_time) | str('?').repeat(1)))
    end

    rule(:task_time_info) do
      (str('[') >> start_time_end_time >> str(']') >> space).maybe >>
      (str('[') >> hour_strict.as(:fixed_start_time) >> str(']') >> space).maybe >>
      (str('[') >> integer.as(:duration) >> str(']') >> space).maybe
    end

    rule(:metadata) { (str("\n").absent? >> any).repeat.as(:str) }

    rule(:task_body) { indent.as(:indent) >> task_time_info.maybe >> task_desc.as(:body) >> tag.repeat.as(:tags) }
    rule(:metadata_block) { (nl.maybe >> str('  ') >> metadata).repeat(0).as(:lines) }
    # ^ nl.maybe is becase tags are eating nl's

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

    rule(:time_until) do
      (str('until') | str('till')) >> space >> hour.as(:end_time)
    end

    rule(:time_frame_header) do
      time_frame_desc.as(:name) >> (lparen >> (time_range | time_from | time_until) >> rparen).maybe >> nl # replaced nl_or_eof to fix the hang.
    end

    rule(:time_frame_with_tasks) { (time_frame_header >> task.repeat.as(:items)).as(:time_frame) } # ...

    rule(:day_tag) { str('@') >> (match('\s').absent? >> any).repeat.as(:tag) >> space? }
    rule(:day_tags) { day_tag.repeat(1).as(:tags) >> nl.maybe }

    rule(:time_frames_with_tasks) { day_tags.maybe >> time_frame_with_tasks.repeat(0) }

    root(:time_frames_with_tasks)
  end
end
