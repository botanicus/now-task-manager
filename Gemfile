# frozen_string_literal: true

source 'https://rubygems.org/'

gemspec

# Optional dependency of the config command.
gem 'coderay'

group(:development) do
  gem 'pry'
  gem 'rubocop'

  gem 'github-markup'
  gem 'redcarpet'
  gem 'ronn'
  gem 'yard'
  gem 'yard-rspec'
end

group(:test) do
  gem 'rspec'
  gem 'timecop'
end

group(:travis) do
  gem 'coveralls'
end
