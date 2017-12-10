_This document is WIP._

# Getting started

_If you don't understand any term, read [terms](https://github.com/botanicus/pomodoro/blob/master/doc/terms.md)_

1. Define your schedules.

There are two types of tasks: tasks to be done **today** and **scheduled tasks**.


## Schedules

The real fun starts with using schedules.

```ruby
# ~/.config/pomodoro/schedules/base.rb
rule(:weekday, -> { today.weekday? }) do |tasks|
  tasks.push(*morning_ritual_tasks)
  tasks << Pomodoro::Task.new('TopTal.', 20, [:online, :work])
  tasks << work_tasks[rand(work_tasks.length)]
  tasks.push(*lunch_break_tasks)
  tasks << Pomodoro::Task.new(project_of_the_week, 90, [:project_of_the_week, :online])
  tasks << cleanup_tasks[rand(cleanup_tasks.length)]
  tasks.push(*evening_tasks)
end
```

# Configuration

```yaml
# ~/.config/pomodoro.yml
---
schedule:  ~/Dropbox/Data/Data/Pomodoro/Schedules/schedules.rb
routine:   ~/Dropbox/Data/Data/Pomodoro/Schedules/base.rb
today:     ~/Dropbox/Data/Data/Pomodoro/Tasks/%Y-%m-%d.today
task_list: ~/Dropbox/Data/WIP/tasks.todo
```

- [today format](https://github.com/botanicus/pomodoro/blob/master/doc/formats/today.md)
- [schedule task list format](https://github.com/botanicus/pomodoro/blob/master/doc/formats/scheduled.md)
