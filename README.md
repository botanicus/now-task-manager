# About

[![Gem version][GV img]][Gem version]
[![Build status][BS img]][Build status]
[![Coverage status][CS img]][Coverage status]
[![CodeClimate status][CC img]][CodeClimate status]
[![YARD documentation][YD img]][YARD documentation]

**Now Task Manager** is a daily planner & focus app *for programmers*. It helps
you plan your day, stay focused and track your time.

It doesn't replace either GTD or the pomodoro technique, it complements them.
(In fact there will be a [Pomodoro plugin #18](https://github.com/botanicus/now-task-manager/issues/18) at some point.)

At some point I must have tried every bloody time management app there is (and let
me tell you, there's a lot of them) and I was still disorganised and eventually
went back to tracking my tasks in a plain text file.

And that's what <abbrev title="Now Task Manager">NTM</abbrev> is using: just plain
text files. But plain text files by themselves didn't help me: after all, that was
what I begun with.

The problem I was always facing was what to do when. As a freelancer, I can do
generally do anything anytime. That's great on one hand, on the other hand it
takes much more discipline. Typical problems:

- Work too much time on one project and too little time on another one.
- Starting a day with a great idea, coding half a day and then working on clients
  projects late at night.
- Missing incremental steps to my long-term goals, like doing every morning Spanish
  revision.

Everything started to turn around when I started to adapt what I call **time framing**:
time framing is about splitting your day into several blocks with clear start time
and end time and within the block doing only tasks that are related to that block.

So <abbrev title="Now Task Manager">NTM</abbrev> is an automation based on my plain
text task files where you define your schedule and then forces you to stick to it.

![Workflow diagram](https://raw.githubusercontent.com/botanicus/now-task-manager/master/doc/diagram.png)

Read about the [benefits](https://github.com/botanicus/now-task-manager/blob/master/doc/benefits.md).

## What it's not

Firstly, this is **not a project management** or **GTD system**: there is no
concept of a project. Here it's all about chunks of time (days and time frames)
and populating them with tasks from do-it-later lists as well as automatically.

You might very well need such system and that's fine: I use GH issues just for that,
in addition to using Pomodoro. But Pomodoro is the corner stone of my day organisation,
GH issues are place to dump to tasks, then link them from Pomodoro.

For the same reason it doesn't deal with **priorities**. If it's not a priority,
why would you put it on today's todo list?

_**Read next**: the [workflow](https://github.com/botanicus/now-task-manager/blob/master/doc/workflow.md)._

[Gem version]: https://rubygems.org/gems/now-task-manager
[Build status]: https://travis-ci.org/botanicus/now-task-manager
[Coverage status]: https://coveralls.io/github/botanicus/now-task-manager
[CodeClimate status]: https://codeclimate.com/github/botanicus/now-task-manager/maintainability
[YARD documentation]: http://www.rubydoc.info/github/botanicus/now-task-manager/master

[GV img]: https://badge.fury.io/rb/now-task-manager.svg
[BS img]: https://travis-ci.org/botanicus/now-task-manager.svg?branch=master
[CS img]: https://img.shields.io/coveralls/botanicus/now-task-manager.svg
[CC img]: https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability
[YD img]: http://img.shields.io/badge/yard-docs-blue.svg
