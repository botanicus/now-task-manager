# About

[![Gem version][GV img]][Gem version]
[![Build status][BS img]][Build status]
[![Coverage status][CS img]][Coverage status]
[![YARD documentation][YD img]][YARD documentation]

_Time management technique based on time framing and a command-line task management tool._

This is something between GTD and the pomodoro technique: it has part of the depth of GTD and part of the immediate action management approach of pomodoro. It is a full-circle task management method.

It does also time tracking which can be used to count actual time worked for clients.

## The workflow

### Planning

In the evening you'll do `pomodoro edit tomorrow`. This will check your schedules and picks one to use. Schedule is a list of time frames, for instance for a work day we could have something like this:

```
Morning routine (from 7:50)
Work for client 1 (9:20 – 12:00)
Lunch break (12:00 – 13)
Work for client 2 (13 – 18)
```

Then it will try to prepopulate the schedule with tasks. There will be various sources:

- The scheduled lists.
- Automatically scheduled tasks.
- Unfinished tasks from today and postponed tasks.

## Doing

3. Next day you simply start getting through your list using `pomodoro next` and `pomodoro complete` (as well as `pomodoro postpone` and `pomodoro move_on`).

The tasks will be looked for in the current time frame. That is even if you have unfinished tasks, if a new time frame started, the tool will pick a task from the newly started one.

## Getting started

1. Define your schedules.

There are two types of tasks: tasks to be done **today** and **scheduled tasks**.

### Today tasks

![](https://raw.githubusercontent.com/botanicus/pomodoro/master/doc/img/today-annotated.png)

- Tasks are stored in readable plain text format.
- Command-line interface.
- [Vim plugin](https://github.com/botanicus/pomodoro/tree/master/support/vim).
- BitBar plugin.

### Scheduled tasks

Scheduled tasks are either scheduled for a certain **date** (tomorrow, next Friday etc), for a ceratin **context** (next time I'm in Prague etc) or just generally for **later**.

```
Tomorrow
- Buy milk.

Prague
- Pick up my shoes.

Later
- Fix the expense gem.
```

That's all there is to it. It's a simple text file and you can edit it to your liking.

The only shortcut you get is `pomodoro + Another task.` which will add a task to the list for later.

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

[Gem version]: https://rubygems.org/gems/pomodoro
[Build status]: https://travis-ci.org/botanicus/pomodoro
[Coverage status]: https://coveralls.io/github/botanicus/pomodoro
[YARD documentation]: http://www.rubydoc.info/github/botanicus/pomodoro/master

[GV img]: https://badge.fury.io/rb/pomodoro.svg
[BS img]: https://travis-ci.org/botanicus/pomodoro.svg?branch=master
[CS img]: https://img.shields.io/coveralls/botanicus/pomodoro.svg
[YD img]: http://img.shields.io/badge/yard-docs-blue.svg
