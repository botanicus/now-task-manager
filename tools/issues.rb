#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'http'
require 'refined-refinements/colours'

API_BASE = 'https://api.github.com'
REPO = 'botanicus/now-task-manager'
POINTS_ARRAY = ['1 pt', '2 pts', '3 pts', '5 pts'].freeze
SUBPROJECTS  = ['BitBar', 'CLI', 'Vim', 'Loop', 'Scheduled format', 'Today format', 'User Ruby code'].freeze

using RR::ColouredTerminal

def retrieve_issues(url)
  puts "<bright_black>~ HTTP GET #{url}.</bright_black>"
  request = HTTP.get(url)
  data = request.body
  issues = JSON.parse(data)
  match = request.headers['Link']&.match(/<(https:.+)>; rel="next"/)
  if next_url = match && match[1]
    issues += retrieve_issues(next_url)
  end
  issues
end

# Main.
issues = retrieve_issues("#{API_BASE}/repos/#{REPO}/issues?state=open")
puts

current_estimated_issues = issues.select do |issue|
  labels = issue['labels'].map { |label| label['name'] }
  !(labels & POINTS_ARRAY).empty? && !labels.include?('Later')
end

results = SUBPROJECTS.each_with_object(Hash.new) do |subproject, buffer|
  buffer[subproject] = Array.new

  current_estimated_issues.map do |issue|
    labels = issue['labels'].map { |label| label['name'] }
    if labels.include?(subproject) && (issue['milestone'] && issue['milestone']['title'] == "Version 0.2")
      buffer[subproject] << "[<yellow>#{(labels & POINTS_ARRAY)[0]}</yellow>] #{issue['title']}"
    end
  end

  if buffer[subproject].empty?
    buffer.delete(subproject)
  else
    total = buffer[subproject].sum { |line| line.match(/\d+/)[0].to_i }
    buffer[subproject] << "<bold>Total: <yellow>#{total} pts</yellow></bold>"
  end
end

overall_total = results.reduce(0) { |sum, (_, lines)| sum + lines[-1].match(/\d+ pt/)[0].to_i }
results.each do |key, lines|
  puts "<cyan>#</cyan> <magenta>#{key}</magenta>\n- #{lines.join("\n- ")}\n\n"
end
puts "<bold>Overall total: <yellow>#{overall_total} pts</yellow></bold>"
