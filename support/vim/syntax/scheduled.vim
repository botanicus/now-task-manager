" Pomodoro scheduled task list syntax file
" https://github.com/botanicus/now-task-manager

if exists("b:current_syntax")
  finish
endif

syn match traskGroupHeader '^[^-]\+$'
syn match taskDefStart '^- '
syn match timeFrame '\[.\+\]'
syn match scheduledHour '\[\d\+:\d\+\]'
syn match tag '#\w\+'

let b:current_syntax = "scheduled"

hi def link traskGroupHeader Statement
hi def link taskDefStart Constant
hi def link timeFrame Statement
hi def link scheduledHour Todo
hi def link tag Type
