require_relative './routines.rb'
require_relative './projects.rb'

rule(:weekday, -> { ! today.saturday? || today.sunday? }) do |tasks|
  # Time frames:
  #   MR 9:20 – 10:20
  #   work 10:20 – 12:20
  #   lunch 12:20 – 14:00,
  #   computer 14:00 – 16:00
  #   offline 19:20 onwards
  tasks << *morning_ritual_tasks
  tasks << Pomodoro::Task.new('TopTal.', 20, [:online, :work])
  tasks << Pomodoro::Task.new(project_of_the_week, 20, [:project_of_the_week, :online])
  tasks << *evening_tasks
end

rule(:blog_post, -> { today.tuesday? }) do |tasks|
  tasks.delete_if { |task| task.tags.include?(:project_of_the_week) }
  tasks.unshift(Pomodoro::Task.new('Write a blog post.', 90, [:online]))
end

rule(:swimming, -> { today.wednesday? }) do |tasks|
  tasks.delete_if { |task| task.tags.include?(:morning_ritual) }
  tasks.unshift(Pomodoro::Task.new('Swimming.', 90, [:morning_ritual]))
end

# Some physical shit, jogging, exercise, posture.
rule(:saturday, -> { today.saturday? }) do |tasks|
  tasks << *morning_ritual_tasks
  tasks << Pomodoro::Task.new('Wing chun.', 90)
  tasks << Pomodoro::Task.new('Pilates or yoga.', 90)
  tasks << *evening_tasks
end

# No set time frame.
rule(:sunday, -> { today.sunday? }) do |tasks|
  switch_project_of_the_week

  tasks << *morning_ritual_tasks
  tasks << Pomodoro::Task.new('Reflect on the week.', 90)
  tasks << Pomodoro::Task.new('Journaling.', 90)
  tasks << *evening_tasks
end

rule(:first_day_of_a_month, -> { today.day == 1 }) do |tasks|
  tasks << Pomodoro::Task.new('Review SwingPlanit and BluesCal.com.', 20)
end

rule(:last_day_of_a_month, -> { last_work_day_of_a_month == Date.today }) do |tasks|
  tasks << Pomodoro::Task.new('Buy things from the wish list.', 20, [:online])
end

rule(:pick_random_cleanup_task, -> { true }) do |tasks|
  tasks << cleanup_tasks[rand(cleanup_tasks.length)]
end

rule(:communications, -> { today.monday? or today.friday? }) do |tasks|
  if today.monday?
    tasks << Pomodoro::Task.new('Gmail, messenger', 20, [:online])
  else
    tasks << Pomodoro::Task.new('Gmail inbox 0, messenger, Skype', 20, [:online])
  end
end
