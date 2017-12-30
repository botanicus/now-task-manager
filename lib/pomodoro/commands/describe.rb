class Pomodoro::Commands::Describe < Pomodoro::Commands::Command
  def run
    puts Pomodoro::Commander.commands.map { |key, cmd|
      next unless cmd.description
      "#{key}:#{cmd.description.gsub("'", "''")}"
    }.compact.join("\n")
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end
end
