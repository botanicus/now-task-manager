# frozen_string_literal: true

require 'yaml'
require 'i18n'

path = File.expand_path('../../i18n/en.yml', __dir__)
I18n.backend.store_translations(:en, YAML.safe_load(File.read(path)))
I18n.default_locale = :en
