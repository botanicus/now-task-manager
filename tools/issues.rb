#!/usr/bin/env ruby

require 'json'
require 'http'

API_BASE = 'https://api.github.com'
REPO = 'botanicus/now-task-manager'
POINTS_ARRAY = ['1 pt', '2 pts', '3 pts', '5 pts']
SUBPROJECTS  = ['BitBar', 'CLI', 'Vim', 'Loop', 'Scheduled format', 'Today format', 'User Ruby code']

def retrieve_issues(url)
  puts "~ HTTP GET #{url}."
  request = HTTP.get(url)
  data = request.body
  issues = JSON.parse(data)
  match = request.headers['Link'].match(/<(https:.+)>; rel="next"/)
  if next_url = match && match[1]
    issues += retrieve_issues(next_url)
  end
  issues
end

# Main.
issues = retrieve_issues("#{API_BASE}/repos/#{REPO}/issues?state=open")

current_estimated_issues = issues.select do |issue|
  labels = issue['labels'].map { |label| label['name'] }
  ! (labels & POINTS_ARRAY).empty? && ! labels.include?('Later')
end

results = SUBPROJECTS.reduce(Hash.new) do |buffer, subproject|
  buffer[subproject] = Array.new

  current_estimated_issues.map do |issue|
    labels = issue['labels'].map { |label| label['name'] }
    if labels.include?(subproject) && (issue['milestone'] && issue['milestone']['title'] == "Version 1.0")
      buffer[subproject] << "[#{(labels & POINTS_ARRAY)[0]}] #{issue['title']}"
    end
  end

  total = buffer[subproject].sum { |line| line.match(/\d+/)[0].to_i }
  buffer[subproject] << "Total: #{total} pts"

  buffer
end

overall_total = results.reduce(0) { |sum, (_, lines)| sum + lines[-1].match(/\d+/)[0].to_i }
results.each do |key, lines|
  puts "# #{key}\n- #{lines.join("\n- ")}\n\n"
end
puts "Overall total: #{overall_total} pts"
