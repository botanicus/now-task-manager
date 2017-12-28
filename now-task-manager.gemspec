#!/usr/bin/env gem build

require 'refined-refinements/colours'

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

  s.files       = Dir.glob('{bin,lib,doc,man,i18n,support}/**/*.{rb,md}') + ['README.md', '.yardopts']
  s.executables = Dir['bin/*'].map(&File.method(:basename))

  s.add_runtime_dependency('parslet', ['~> 1.8'])
  s.add_runtime_dependency('term-ansicolor', ['~> 1.4'])
  s.add_runtime_dependency('refined-refinements', ['~> 0.0.2.1'])
  s.add_runtime_dependency('i18n', ['~> 0.9'])

  # s.post_install_message = <<-EOF.gsub(/^\s*/, '').colourise
  #   <green.bold>Welcome to NTM!</green.bold>
  #
  #   <green>Setup</green> wizzard: <bright_black>now setup</bright_black>
  #   To create the config and install ZSH and Vim plugins.
  #
  #   Get the <magenta>man pages</magenta>:
  #   <bright_black>gem install manpages && gem manpages --update-all</bright_black>
  #
  #   Install dependencies for the <yellow>task loop</yellow>:
  #   <bright_black>gem install rufus-scheduler filewatcher</bright_black>
  # EOF
end
