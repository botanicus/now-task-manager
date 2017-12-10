#!/usr/bin/env gem build

Gem::Specification.new do |s|
  s.name        = 'now-task-manager'
  s.version     = '0.1.0'
  s.authors     = ['James C Russell']
  s.email       = 'james@101ideas.cz'
  s.homepage    = 'http://github.com/botanicus/now-task-manager'
  s.summary     = ''
  s.description = "#{s.summary}."
  s.license     = 'MIT'
  s.metadata['yard.run'] = 'yri' # use 'yard' to build full HTML docs.

  s.files       = Dir.glob('{bin,lib,doc}/**/*.{rb,md}') + ['README.md']
  s.executables = Dir['bin/*'].map(&File.method(:basename))

  s.add_runtime_dependency('parslet', ['~> 1.8'])
  s.add_runtime_dependency('term-ansicolor', ['~> 1.4'])
  s.add_runtime_dependency('refined-refinements', ['~> 0.0'])
end
