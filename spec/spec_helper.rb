
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'
require 'vcr'
require 'webmock/rspec'
require "paperclip/matchers"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/shared/ and its subdirectories.
Dir[Rails.root.join("spec/shared/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)


# Configruation for VCR
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.default_cassette_options = { record: :once }
  c.hook_into :webmock
  # c.ignore_hosts 'api.stripe.com'

  # Configure VCR and Rspec
  c.configure_rspec_metadata!

  # Filters for external API's
  c.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }
  c.filter_sensitive_data('<AWS_ID>') { ENV['AWS_ID'] }
  c.filter_sensitive_data('<AWS_KEY>') { ENV['AWS_KEY'] }

  # Setup a custom matcher to remove the object id when comparing AWS S3
  # requests. This will prevent re-recording vcr transactions for S3.
  c.register_request_matcher :aws do |req1, req2|
    path1 = URI(req1.uri).path.gsub(/\d+\S+\//, '') # Remove object id
    path2 = URI(req2.uri).path.gsub(/\d+\S+\//, '')
    path1 == path2
  end

  c.register_request_matcher :stripe_get_customer do |req1, req2|
    return false if req1.method != req2.method
    if req1.uri =~ /api.stripe.com\/v1\/customers/
      path1 = req1.uri.gsub(/\/\d+/, '') # Remove customer id
      path2 = req2.uri.gsub(/\/\d+/, '')
      path1 == path2
    else
      req1.uri == req2.uri
    end
  end
end

RSpec.configure do |config|
  # default, enables both `should` and `expect`
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Include devise helpers for testing controllers
  config.include Devise::TestHelpers, type: :controller

  # Include Stripe.com test helpers
  config.include StripeTestHelpers

  # Clean and truncate database before each test run, include
  # error test runs
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  # Paperclip support for testing
  #config.include Paperclip::Shoulda::Matchers
end

# Add custom matcher for mongoid attachment
RSpec::Matchers.define :have_mongoid_attached_file do |expected|
  match do |actual|
    have_fields(":#{actual}_content_type", ":#{actual}_file_name", ":#{actual}_file_size", ":#{actual}_updated_at")
  end
end
