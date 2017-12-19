class Pomodoro::Commands::Config < Pomodoro::Commands::Command
  using RR::ColourExts

  self.help = <<-EOF.gsub(/^\s*/, '')
    now config today_path
    now config today_path 2017-12-19
  EOF

  def run
    if @args.empty?
      p config
    else
      args = @args[1..-1].map { |a| a.match(/^\d{4}-\d{2}-\d{2}$/) ? Date.parse(a) : a }
      puts self.config.send(@args[0], *args)
    end
  end
end
