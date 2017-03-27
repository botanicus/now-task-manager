#!/usr/bin/env gem build

Gem::Specification.new do |s|
  s.name        = 'pomodoro'
  s.version     = '0.0.1'
  s.authors     = ['James C Russell']
  s.email       = 'james@101ideas.cz'
  s.homepage    = 'http://github.com/botanicus/pomodoro'
  s.summary     = ''
  s.description = "#{s.summary}."
  s.license     = 'MIT'

  s.files       = Dir.glob('{bin,lib}/**/*.rb') + ['README.md']
  s.executables = Dir['bin/*'].map(&File.method(:basename))

  s.add_runtime_dependency('term-ansicolor', ['~> 1.4'])
  s.add_runtime_dependency('refined-refinements', ['~> 0.0'])
end
