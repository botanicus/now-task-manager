#!/usr/bin/env ruby

require 'pp'
require 'parslet'

class TodoParser < Parslet::Parser
  # Primitives.
  rule(:indent)  { match['-✓✔✕✖✗✘'].repeat(1, 1) >> space }
  rule(:integer) { match['0-9'].repeat(1) >> space? }
  rule(:nl)      { str("\n").repeat(1) }

  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  rule(:lsquare_bracket) { str('[') }
  rule(:rsquare_bracket) { str(']') }
  rule(:time_delimiter)  { str('-') }
  rule(:colon)  { str(':') }

  rule(:hour) { integer >> colon >> integer }
  rule(:desc) { match['^\n'].repeat(1) }
  # rule(:desc) { match('[^\n#]').repeat(1) }

  # [20]
  rule(:set_duration)     { lsquare_bracket >> integer.as(:duration) >> rsquare_bracket >> space }
  # [9:30-]
  rule(:fixed_start_time) { lsquare_bracket >> hour.as(:fixed_start_time) >> rsquare_bracket >> space }
  rule(:period)           { lsquare_bracket >> hour.as(:period_from) >> time_delimiter >> hour.maybe.as(:period_to) >> rsquare_bracket >> space }
  rule(:time_info)        { set_duration | period | fixed_start_time}

  rule(:tag) { str('#') >> word >> space? }
  # rule(:tag) { match('#\w+\s*') }

  rule(:word) { match['a-zA-Z'].repeat(1).as(:word) >> space? }
  rule(:task)      { indent.as(:indent) >> time_info.maybe >> desc.as(:desc) >> tag.repeat.as(:tags) }
  rule(:task_list) { (task >> nl).repeat }

  ###
  rule(:time_frame) { match('[^\n]').repeat.as(:time_frame) }

  rule(:expression) { task_list | time_frame }
  root(:expression)
end

class SimpleTransform < Parslet::Transform
  rule(task: 'puts', arglist: sequence(:args)) {
    "puts(#{args.inspect})"
  }
  # ... other rules
end


begin
  parser = TodoParser.new
  pp parser.parse(DATA.read)
rescue Parslet::ParseFailed => failure
  puts failure.parse_failure_cause.ascii_tree
end

__END__
Test
- [20] ABC #yes
- [9:30] ABC
- [9:30-10:20] ABC
✔ ABC
