class Pomodoro::Commands::Config < Pomodoro::Commands::Command
  self.description = "Print out <magenta>configuration</magenta>."

  self.help = <<-EOF.gsub(/^\s*/, '')
    now <yellow>config</yellow>
    now <yellow>config</yellow> today_path
    now <yellow>config</yellow> today_path 2017-12-19
  EOF

  def run
    if @args.empty?
      p config
    else
      unless @config.respond_to?(@args.first)
        abort "<red>...</red>"
      end

      puts self.config.send(@args.first, *convert_arguments)
    end
  rescue Pomodoro::Config::ConfigError => error
    abort "<red>#{error.message}</red>"
  end

  private
  def convert_arguments
    @args[1..-1].map do |argument|
      argument.match(/^\d{4}-\d{2}-\d{2}$/) ? Date.parse(argument) : argument
    end
  end
end
