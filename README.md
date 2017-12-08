# About [![Travis](https://travis-ci.org/botanicus/pomodoro.svg?branch=master)](https://travis-ci.org/botanicus/pomodoro) [![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/botanicus/pomodoro/master)

Simple command-line task management tool supporting time framing.

![](https://raw.githubusercontent.com/botanicus/pomodoro/master/doc/img/today-annotated.png)

- Tasks are stored in readable plain text format.
- Command-line interface.
- [Vim plugin](https://github.com/botanicus/pomodoro/tree/master/support/vim).
- BitBar plugin.

## Time Framing

[today format](https://github.com/botanicus/pomodoro/blob/master/doc/formats/today.md)
[schedule task list format](https://github.com/botanicus/pomodoro/blob/master/doc/formats/scheduled.md)

## Why?

- Schedules, task archive.
- Increase awareness.
- No skipping.
- End-of-the day/week reports for clients (incl. how much to charge).
- Offlining.
- Make your work easier with `git commit-pomodoro`.

# Tutorial

## Basic usage

1. Write your task file.
2. Use `pomodoro next` to get through the task list.
   Note that there is no skipping or chosing which task you want to work on.
   That's exactly the point.
3. At the end of the day use `pomodoro punch-off`.

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

## BitBar plugin

[BitBar](https://getbitbar.com/)

```shell
tee ~/.bitbar/pomodoro.1s.sh <<EOF
#!/bin/sh

log-time --bitbar
EOF
```

![](https://raw.githubusercontent.com/botanicus/pomodoro/master/doc/more-than-5m.png)
![](https://raw.githubusercontent.com/botanicus/pomodoro/master/doc/less-than-5m.png)

## ZSH prompt.

![](https://raw.githubusercontent.com/botanicus/pomodoro/master/doc/prompt.png)

## Limiting online access

_TODO_
This is why I wrote it in the first place.

## OS X notifications

`~/Library/LaunchAgents/botanicus.pomodoro_notification.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>botanicus.pomodoro_notification</string>

    <key>ProgramArguments</key>
    <array>
      <string>zsh</string>
      <string>-c</string>
      <string>pomodoro-loop</string>
    </array>

    <key>RunAtLoad</key>
    <true />

    <key>KeepAlive</key>
    <true />

    <!-- I don't have permissions to write into /var/log. -->
    <key>StandardOutPath</key>
    <string>/tmp/botanicus.pomodoro_notification.stdout</string>
    <key>StandardErrorPath</key>
    <string>/tmp/botanicus.pomodoro_notification.stderr</string>
  </dict>
</plist>
```

```shell
launchctl load -w ~/Library/LaunchAgents/botanicus.pomodoro_notification.plist
```
