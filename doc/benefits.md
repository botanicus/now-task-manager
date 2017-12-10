_This document is WIP._

- Separating planning from execution.
- Predictable schedules.
- Task statuses. Where did you ended, why was it postponed and how long for?

don't let your work and errands kill your personal objectives. Learning Spanish etc.

plan, review
scrum uses time framing as well (sprints)
time framing here is different: it's not about deliverables (you can work on a project ad infinitum), it's about the routines and project scheduling (it's all bottom-up).

USE POMODORO WITHIN for durations? This can be available via plugins.
Example: pomodoros are not useful for everything. Like going to a bank,
you never know how long it's going to take (esp. if you live in Poland).
The only thing that is certain is that you have to fit it within a time frame,
because you have to get your client's work done.

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

For instance let's see how much time have I spent on admin in the first quarter of 2017:

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

Or you can want to know how good your estimates are. You've been adding a custom
metadata such as `Estimate: 4h` to your tasks. Now you can go and compare the estimate
with the actual duration of the task.

Read the [workflow](https://github.com/botanicus/pomodoro/blob/master/doc/workflow.md)
to understand how it works.
