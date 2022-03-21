source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.3"

gem "rails", "~> 7.0.2", ">= 7.0.2.2"
gem "sprockets-rails"
gem "pg"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "activestorage" , ">= 7.0.2.3"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gem "faker", "~> 2.19"

gem "rubocop", "~> 1.25", require: false

gem "devise"

gem "acts_as_votable"
gem "pundit", "~> 2.2"

gem "friendly_id", "~> 5.4"

gem "meta-tags", "~> 2.16"

gem "omniauth-github", github: 'omniauth/omniauth-github', branch: 'master'
gem "omniauth-rails_csrf_protection" # for omniauth 2.0
