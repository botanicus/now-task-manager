# About

[![Gem version][GV img]][Gem version]
[![Build status][BS img]][Build status]
[![Coverage status][CS img]][Coverage status]
[![YARD documentation][YD img]][YARD documentation]

FocusList is a daily planner & focus app based on Pomodoro technique. It helps you plan your day, stay focused and track your time. http://focuslist.co/

Practical task management tool with time tracking based on:
- Separating planning from execution.
- Predictable schedules.
- Task statuses. Where did you ended, why was it postponed and how long for?

## What it's not

Firstly, this is **not a project management** or **GTD system**: there is no concept of a project.
Here it's all about chunks of time (days and time frames) and populating them with tasks
from do-it-later lists as well as automatically.

You might very well need such system and that's fine: I use GH issues just for that,
in addition to using Pomodoro. But Pomodoro is the corner stone of my day organisation,
GH issues are place to dump to tasks, then link them from Pomodoro.

For the same reason it doesn't deal with **priorities**. If it's not a priority, why would you put it on today's todo list?

## What it could be

POMODOROTECHNIQUE - it can live alongside, using a plugin, an external system or a manual timer.

NAMES: balance(not gem), routine, habit, focus (not gem) flow

don't let your work and errands kill your personal objectives. Learning Spanish etc.

plan, review
scrum uses time framing as well (sprints)
time framing here is different: it's not about deliverables (you can work on a project ad infinitum), it's about the routines and project scheduling (it's all bottom-up).

USE POMODORO WITHIN for durations? This can be available via plugins.
Example: pomodoros are not useful for everything. Like going to a bank,
you never know how long it's going to take (esp. if you live in Poland).
The only thing that is certain is that you have to fit it within a time frame,
because you have to get your client's work done.

- [14:00-15:30] Fix #86. # <= what needs to get done
  - [14:00-14:25] Reproduce the bug. # <= time log using pomodoro
  - [14:32-14:57] Reproduce the bug. # Pomodoro restarted. And I took a 7 min-long break.
  - [15:05-15:30] Write a test.


OR the [duration] is actually estimate and then we can see how we are doing and actually count how good our estimate is
[ ]
[-]
[p]
[✘]
[✔]
OR ✔/✘/- OR [p] etc

PLUGIN structure important!

pomodoro pomodoro_plugin restart
Any task with #pomodoro

Pluggable backend (dir/mysql ...)

! POMODOROs: useful reports for clients. But the time is still reported via tiem frames.

I'm not a time management expert, but this is the practical solution that made my life infinitely more organised.

- Schedules, task archive.
- Increase awareness.
- No skipping.
- End-of-the day/week reports for clients (incl. how much to charge).
- Offlining.
- Make your work easier with `git commit-pomodoro`.


_Time management technique based on time framing and a command-line task management tool._

This is something between GTD and the pomodoro technique: it has part of the depth of GTD and part of the immediate action management approach of pomodoro. It is a full-circle task management method.

It does also time tracking which can be used to count actual time worked for clients.

## Benefits

### Holistic

I tried pomodoro and it's great, but it doesn't see the big picture.

The pomodoro technique is great to force you to do the work and not procrastinating.

It doesn't help you to keep several client projects in the air while you have your
personal goals and responsibilities.

- Holistic. It's not just for the work or just for home.
- Defaults. Don't think.
- Automatically tracking time for clients.

## It doesn't make you think

Tasks are sequential. You cannot choose which task to work on next. The next task down the list is the one that's coming next.

Schedules are automatic.

Will power limited.

## Rich data

**Time tracking** (optional): Time tracking is useful if you are paid for your time or if you want to run any useful stats.

Task **status** and **metadata**

**Journaling**

## Data is yours

The data are in simple plain text and you get a Ruby library to parse them and do whatever you want.

For instance let's see how much time have I wasted on admin in the first quarter of 2017:

```ruby
require 'pomodoro'

Pomodoro.load('2017/{1,2,3}').each do |task_list|
  task_list.reduce(0) do |sum, time_frame|
    if time_frame.tags.include?(:admin)
      sum + time_frame.duration
    else
      sum
    end
  end
end
```

# What's next?

- [workflow](https://github.com/botanicus/pomodoro/blob/master/doc/workflow.md)
- [getting-started](https://github.com/botanicus/pomodoro/blob/master/doc/getting-started.md)
- [terms](https://github.com/botanicus/pomodoro/blob/master/doc/terms.md)
- [today format](https://github.com/botanicus/pomodoro/blob/master/doc/formats/today.md)
- [schedule task list format](https://github.com/botanicus/pomodoro/blob/master/doc/formats/scheduled.md)



[Gem version]: https://rubygems.org/gems/pomodoro
[Build status]: https://travis-ci.org/botanicus/pomodoro
[Coverage status]: https://coveralls.io/github/botanicus/pomodoro
[YARD documentation]: http://www.rubydoc.info/github/botanicus/pomodoro/master

[GV img]: https://badge.fury.io/rb/pomodoro.svg
[BS img]: https://travis-ci.org/botanicus/pomodoro.svg?branch=master
[CS img]: https://img.shields.io/coveralls/botanicus/pomodoro.svg
[YD img]: http://img.shields.io/badge/yard-docs-blue.svg
