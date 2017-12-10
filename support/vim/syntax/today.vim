" Pomodoro today syntax file
" https://github.com/botanicus/now-task-manager

if exists("b:current_syntax")
  finish
endif

" TODO:
" Groups so we can fold time frames.
" Hide time frames where everything is done.

syn match timeFrameLabel '^[^#-][a-zA-Z0-9 ]\+'
syn match taskDef '^- '
syn match comment '#.*$'
syn match hour '\d\+:\d\+'
syn match scheduledHour '\[\d\+:\d\+\]'
syn match time '\[\d\+\]'
syn match tag '#\w\+'
syn match finishedTask_1 '^✔.*$'
syn match finishedTask_2 '^- \[\d\+:\d\+-\d\+:\d\+\].*$'
syn match inProgressTask '^- \[\d\+:\d\+-now\].*$'
syn region celDescBlock start=":$" end="\n\n" fold transparent


let b:current_syntax = "today"

hi def link timeFrameLabel Statement
hi def link taskDef Constant
hi def link comment Comment
hi def link hour Type
hi def link scheduledHour Todo
hi def link time Statement
hi def link tag Type
hi def link finishedTask_1 Comment
hi def link finishedTask_2 Comment
hi def link inProgressTask Underlined
