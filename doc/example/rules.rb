# frozen_string_literal: true

time_frame(/morning routine/i) do |time_frame|
  time_frame.create_task('Headspace.')
end

time_frame(/admin/i) do |time_frame|
  time_frame.create_task('Inbox 0.')
end
