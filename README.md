Features to consider
- Timeframing (is it necessary)?
- [50] Pomodoro: add metadata (started, finished, waiting_for).
- [15] Pomodoro: add postponing (with a reason).
- [30] Pomodoro: add stats about total minutes expected and actual to the backup.

# TODO
 system %(osascript -e 'display notification "Times up!" with title "Times up!" sound name "Glass"')

# About

Limit your time online and increase awareness about what you are doing there.

# Installation

```
ln -sf PATH/botanicus.wifi.plist ~/Library/LaunchAgents/botanicus.wifi.plist
launchctl load ~/Library/LaunchAgents/botanicus.wifi.plist
```

# Configuration

```
mkdir ~/.config && tee -a ~/.config/internet-usage-limiter.yml <<EOF
---
 log_file_path: ~/Dropbox/WIP/Internet usage.log
 work_day_work_schedule: ['9:30', '14:00']
 work_day_personal_schedule: ['14:00', '18:20']
 saturday_schedule: ['9:30', '18:20']
EOF
 ```

https://freedom.to/
