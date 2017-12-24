class Pomodoro::Commands::Test < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>test</magenta> [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>] <bright_black># Plan the coming time period.</bright_black>
    now test # Defaults to the current year.
    now test 2018
    now test Q1
  EOF

  def run
    unless @args.first && @args.first.match(/^\d{4}$/)
      @args.unshift(Date.today.year.to_s)
    end

    Dir.chdir(self.config.data_root_path(@args.shift)) do
      puts "<bold>~</bold> Current directory: <green>#{Pomodoro::Tools.format_path(Dir.pwd)}</green>."
      paths = @args.map { |i| "features/#{i}.feature"}
      command("cucumber #{paths.join(' ')}") #bundle exec
    end
  end
end
