# About

[![Gem version][GV img]][Gem version]
[![Build status][BS img]][Build status]
[![Coverage status][CS img]][Coverage status]
[![YARD documentation][YD img]][YARD documentation]

Practical task management tool with time tracking based on:
- Separating planning from execution.
- Predictable schedules.
- Task statuses. Where did you ended, why was it postponed and how long for?

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

[workflow](https://github.com/botanicus/pomodoro/blob/master/doc/workflow.md)
[getting-started](https://github.com/botanicus/pomodoro/blob/master/doc/getting-started.md)
[terms](https://github.com/botanicus/pomodoro/blob/master/doc/terms.md)

[today format](https://github.com/botanicus/pomodoro/blob/master/doc/formats/today.md)
[schedule task list format](https://github.com/botanicus/pomodoro/blob/master/doc/formats/scheduled.md)


[Gem version]: https://rubygems.org/gems/pomodoro
[Build status]: https://travis-ci.org/botanicus/pomodoro
[Coverage status]: https://coveralls.io/github/botanicus/pomodoro
[YARD documentation]: http://www.rubydoc.info/github/botanicus/pomodoro/master

[GV img]: https://badge.fury.io/rb/pomodoro.svg
[BS img]: https://travis-ci.org/botanicus/pomodoro.svg?branch=master
[CS img]: https://img.shields.io/coveralls/botanicus/pomodoro.svg
[YD img]: http://img.shields.io/badge/yard-docs-blue.svg
