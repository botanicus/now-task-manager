# About

Simple command-line [pomodoro](http://cirillocompany.de/pages/pomodoro-technique) client.

## Why?

Schedules, task archive.
Increase awareness.
No skipping.
End-of-the day/week reports for clients (incl. how much to charge).
Offlining.

# Tutorial

## Basic usage

1. Write your task file.
2. Use `pomodoro next` to get through the task list.
   Note that there is no skipping or chosing which task you want to work on.
   That's exactly the point.
3. At the end of the day use `pomodoro punch-off`.

## Schedules

The real fun starts with using schedules.

# Configuration

```shell
mkdir ~/.config && tee -a ~/.config/internet-usage-limiter.yml <<EOF
---
 log_file_path: ~/Dropbox/WIP/Pomodoro.log
 work_day_work_schedule: ['9:30', '14:00']
 work_day_personal_schedule: ['14:00', '18:20']
 saturday_schedule: ['9:30', '18:20']
EOF
```
## BitBar plugin

[BitBar](https://getbitbar.com/)

```shell
tee /.bitbar/pomodoro.1s.sh <<EOF
#!/bin/sh

log-time --bitbar
EOF
```

_TODO: Screenshots._

## Limiting online access

This is why I wrote it in the first place.

# Features under consideration

- Timeframing (is it necessary)?
- [50] Pomodoro: add metadata (started, finished, waiting_for).
- [15] Pomodoro: add postponing (with a reason).
- [30] Pomodoro: add stats about total minutes expected and actual to the backup.

# TODO
 system %(osascript -e 'display notification "Times up!" with title "Times up!" sound name "Glass"')

https://freedom.to/
