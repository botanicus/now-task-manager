# frozen_string_literal: true

# TODO: Rethink plan & test (do we really want to use features)?
# https://github.com/botanicus/now-task-manager/issues/122
class Pomodoro::Commands::Test < Pomodoro::Commands::Command
  self.help = <<-EOF.gsub(/^\s*/, '')
    now <magenta>test</magenta> [<cyan>year</cyan>|<cyan>quarter</cyan>|<cyan>month</cyan>|<cyan>week</cyan>] <bright_black># Plan the coming time period.</bright_black>
    now test # Defaults to the current year.
    now test 2018
    now test Q1
    now test week # Test the last week.
    now test weeks # Test all the weeks.
  EOF

  def run
    @args.unshift(Date.today.year.to_s) unless @args.first&.match(/^\d{4}$/)

    year = @args.shift

    @args.map! do |argument|
      if File.directory?("features/#{argument}") # months, weeks
        "features/#{argument}"
      elsif File.exist?("features/#{argument}.feature") # Q{1-4}
        "features/#{argument}.feature"
      elsif Date::MONTHNAMES.compact.include?(argument)
        "features/months/#{argument}.feature"
      elsif argument.match(/^\d+$/) && (1..52).cover?(argument.to_i)
        "features/weeks/#{argument}.feature"
      end
    end

    Dir.chdir(self.config.data_root_path(year)) do
      puts t(:pwd, dir: RR::Homepath.new(Dir.pwd))
      command("cucumber #{@args.join(' ')}") #bundle exec
    end
  end
end
