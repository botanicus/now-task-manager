https://github.com/blog/2231-building-your-first-atom-plugin

- Writing Vim plugins http://stevelosh.com/blog/2011/09/writing-vim-plugins/
- Vim plugin documentation http://learnvimscriptthehardway.stevelosh.com/chapters/54.html

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
