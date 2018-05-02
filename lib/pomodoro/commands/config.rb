class Pomodoro::Commands::Config < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <yellow>config</yellow>
    now <yellow>config</yellow> today_path
    now <yellow>config</yellow> today_path 2017-12-19
  EOF

  def highlight_or_puts(json)
    require 'coderay'

    puts CodeRay.scan(json, :json).term
  rescue LoadError
    warn "~ Enable syntax highlighting by installing coderay.\n\n"

    puts json
  end

  def run
    if @args.empty?
      puts "<bold>Path:</bold> <bright_black>#{config.path}</bright_black>\n\n"
      highlight_or_puts(JSON.pretty_generate(config.data))
    else
      method_name = @args.first

      unless @config.respond_to?(method_name)
        raise Pomodoro::Config::ConfigError.new(t(:unknown_option, option: method_name))
      end

      value = self.config.send(method_name, *convert_arguments)
      highlight_or_puts(JSON.pretty_generate(value))
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
