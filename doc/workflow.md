_This document is WIP._

## The workflow

_If you don't understand any term, read [terms](https://github.com/botanicus/pomodoro/blob/master/doc/terms.md)_

![Workflow diagram](https://raw.githubusercontent.com/botanicus/pomodoro/master/doc/diagram.png)

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

_**Read next**: [getting started](https://github.com/botanicus/pomodoro/blob/master/doc/getting-started.md)_
