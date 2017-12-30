class Pomodoro::Commands::Config < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <yellow>config</yellow>
    now <yellow>config</yellow> today_path
    now <yellow>config</yellow> today_path 2017-12-19
  EOF

  def run
    if @args.empty?
      p config
    else
      method_name = @args.first

      unless @config.respond_to?(method_name)
        raise Pomodoro::Config::ConfigError.new(t(:unknown_option, option: method_name))
      end

      puts self.config.send(method_name, *convert_arguments)
    end
  rescue Pomodoro::Config::ConfigError => error
    abort error
  end

  private
  def convert_arguments
    @args[1..-1].map do |argument|
      argument.match(/^\d{4}-\d{2}-\d{2}$/) ? Date.parse(argument) : argument
    end
  end
end
