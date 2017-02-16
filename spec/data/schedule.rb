# Projects.
project('Tango')
project('Learning Spanish')

# Rules.
# rule(:weekday, -> { ! today.saturday? || today.sunday? }) do |tasks|
rule(:weekday, -> { true }) do |tasks|
  tasks << Pomodoro::Task.new('Meditation.', 20, [:morning_ritual])
  # tasks << Pomodoro::Task.new('Do some work.', 90, [:work, :online])
  # tasks << Pomodoro::Task.new(random_project, 20, [:project_of_the_week, :online])
  tasks << Pomodoro::Task.new('Plan tomorrow.')
end
