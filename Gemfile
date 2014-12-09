source 'https://rubygems.org'

## STANDARD RAILS 4.1.x Gemset ----------------------------------------

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

##  -------------------------------------------------------------------

## APPLICATION SPECIFIC GEMS ##########################################

gem 'mongoid', "~> 4.0"
gem 'bson_ext'

# UI Related Gems
gem 'foundation-rails'
gem 'will_paginate_mongoid'
gem 'foundation-icons-sass-rails'

# Strip white spaces from the end of attributes
gem 'strip_attributes'

# Authentication and Authorization
gem 'devise', "~> 3.4"
gem 'cancan', "~> 1.6"

# Paperclip GEM for handling file attachments
gem "mongoid-paperclip", :require => "mongoid_paperclip"
gem 'aws-sdk'

# GEM for reading environment variables from a configuration file
gem 'figaro'

# Stripe GEM for interacting with stripe.com payment service
gem 'stripe'

# Rspec, Cucumber and Webrat GEMs for TDD/BDD
group :test, :development do
  gem "factory_girl_rails"
  gem 'rspec-rails'
  gem "capybara"
  gem 'pry-nav'
  gem 'pry-rails'
  gem "webrat"
  gem "database_cleaner"
  gem "vcr"
  gem "webmock"
end

#######################################################################

## SETUP for Heroku ---------------------------------------------------

group :production do
  gem 'rails_12factor'
end

ruby '2.1.5'
