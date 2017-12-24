require 'i18n'

I18n.backend.store_translations(:en, YAML.load(File.read('i18n/en.yml')))
I18n.default_locale = :en
