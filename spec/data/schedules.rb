schedule(:any, -> { true }) do |day|
  day.task_list << time_frame('Morning', nil, '12:00')
  day.task_list << time_frame('Afternoon', '14:00')
end
