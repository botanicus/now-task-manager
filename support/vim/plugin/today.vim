" TODO: Using vim-ruby we can use the library.

function! EditScheduledList()
  let scheduled_list_path = systemlist('now config task_list_path')[0]
  execute 'edit' scheduled_list_path
endfunction

" TODO: Refactor this at some point.
function! EditTomorrowsList()
  let command = "ruby -rdate -e '" . 'puts (Date.today + 1).strftime("%Y-%m-%d")' . "'"
  let tomorrow = systemlist(command)[0]
  let today_list_path = systemlist('now config today_path ' . tomorrow)[0]
  execute 'edit' today_list_path
endfunction

function! EditYesterdaysList()
  let command = "ruby -rdate -e '" . 'puts (Date.today - 1).strftime("%Y-%m-%d")' . "'"
  let tomorrow = systemlist(command)[0]
  let today_list_path = systemlist('now config today_path ' . tomorrow)[0]
  execute 'edit' today_list_path
endfunction

command Scheduled call EditScheduledList()
command! Tomorrow call EditTomorrowsList()
command! Yesterday call EditYesterdaysList()

" Reload file on change (once the editor takes focus).
set autoread

"nmap ta /-now\]/<Enter>:nohl<Enter>f<Space>l
"nmap td ta:s/now/\=strftime('%H:%M')<Enter>
"nmap ts $/^- /<Enter>:s/- /- [%-now] <Enter>:s/%/\=strftime('%H:%M')<Enter>:nohl<Enter>
"nmap <Enter> :call ToggleTaskStatus()<Enter><Enter><C-l>

"function! ToggleTaskStatus()
"ruby <<EOF
"  line = Vim::Buffer.current.line
"
"  if line.match(/^- /)
"    require 'pomodoro/task'
"
"    task = Pomodoro::Task.parse(line)
"
"    case task.status
"    when :unstarted then task.start
"      Vim::Buffer.current.line = task.to_s
"      Vim.message("Task set as started.")
"    when :in_progress then task.finish
"      Vim::Buffer.current.line = task.to_s
"      Vim.message("Task set as finished.")
"    when :finished, :postponed
"      # https://github.com/vim/vim/blob/master/runtime/doc/if_ruby.txt
"      #
"      # Buffer:
"      # [:name, :number, :count, :length, :[], :[]=, :delete, :append, :line_number, :line, :line=]
"      # Window:
"      # [:buffer, :height, :height=, :width, :width=, :cursor, :cursor=]
"      #window = Vim::Window.current
"
"      protector = 1
"      loop do
"        line = Vim::Buffer.current.line
"        protector += 1
"        last_position = Vim::Buffer.current.line_number
"        Vim.command('+1')
"        p [protector, last_position, Vim::Buffer.current.line_number, Pomodoro::Task.parse(line)]
"        if task = Pomodoro::Task.parse(line) || last_position == Vim::Buffer.current.line_number || protector == 10
"          break
"        end
"      end
"    end
"
"    p task
"    puts task.to_s
"  end
"EOF
"endfunction
