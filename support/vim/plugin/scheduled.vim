" Reload file on change (once the editor takes focus).
set autoread

function! EditTodaysList()
  let today_list_path = systemlist('now config today_path')[0]
  execute 'edit' today_list_path
endfunction

" TODO: Refactor this at some point.
function! EditTomorrowsList()
  let command = "ruby -rdate -e '" . 'puts (Date.today + 1).strftime("%Y-%m-%d")' . "'"
  let tomorrow = systemlist(command)[0]
  let today_list_path = systemlist('now config today_path ' . tomorrow)[0]
  execute 'edit' today_list_path
endfunction

command Today call EditTodaysList()
command! Tomorrow call EditTomorrowsList()
