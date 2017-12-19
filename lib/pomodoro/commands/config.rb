class Pomodoro::Commands::Config < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
  EOF

  def run
    # now self.config today_path 2017-12-19
    args = ARGV[1..-1].map { |a| a.match(/^\d{4}-\d{2}-\d{2}$/) ? Date.parse(a) : a }
    puts self.config.send(ARGV[0], *args)
  end
end
