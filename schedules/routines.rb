def morning_ritual_tasks
  Array.new.tap do |tasks|
    tasks << Pomodoro::Task.new('Breakfast & Duolingo.', 40)
    # Blues & swing / salsa.
    tasks << Pomodoro::Task.new('Dancing.', 20, [:dancing, :morning_ritual])
    tasks << Pomodoro::Task.new('Meditation.', 20, [:meditation, :morning_ritual])
    tasks << Pomodoro::Task.new('Review plan for today.', 10, [:morning_ritual])
  end
end

def evening_tasks
  Array.new.tap do |tasks|
    tasks << Pomodoro::Task.new('Dinner & read Pocket articles.', 50)
    tasks << Pomodoro::Task.new('Clean-up.', 20)
    tasks << Pomodoro::Task.new('Headspace.', 20, [:meditation])
    tasks << Pomodoro::Task.new('Plan tomorrow.', 20)
    tasks << Pomodoro::Task.new('Read a book.', 90, [:evening])
  end
end

def cleanup_tasks
  Array.new.tap do |tasks|
    tasks << Pomodoro::Task.new('Reduce Chrome tabs by 20.', 20, [:online])
    tasks << Pomodoro::Task.new('Evernote clean-up.', 20)
    tasks << Pomodoro::Task.new('HD clean-up including apps.', 20)
  end
end
