" Reload file on change (once the editor takes focus).
set autoread

function! EditTodayList()
  let today_list_path = systemlist('now config today_path')[0]
  execute 'edit' today_list_path
endfunction

command Today call EditTodayList()
