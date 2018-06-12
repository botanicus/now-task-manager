# frozen_string_literal: true

# This is much faster, we could create a standalone script for it, but the main
# issue is how to get the path to en.yml. Currently the performance is not an issue,
# but leaving it for now.
#
# puts YAML.load_file('i18n/en.yml')['commands'].reduce(Array.new) { |lines, (name, command)|
#   if command && command['description']
#     lines << [name, command['description']].join(':')
#   end
#
#   lines
# }

class Pomodoro::Commands::Describe < Pomodoro::Commands::Command
  def run
    puts Pomodoro::Commander.commands.map { |key, cmd|
      next unless cmd.description
      "#{key}:#{cmd.description.gsub("'", "''")}"
    }.compact.join("\n")
  end
end
