require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
# Bundler.require(:default, Rails.env)
Bundler.require(*Rails.groups)

module AssetKeeper
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Default local host for mailer - over ride in different environments
    config.action_mailer.default_url_options = { host: 'localhost:3000' }

    # Raise mailer exceptions
    config.action_mailer.raise_delivery_errors = true
    # Paperclip configuration for S3 storage
    config.paperclip_defaults = {
      storage: :s3,
      s3_credentials: {
        bucket: ENV['AWS_S3BUCKET'],
        access_key_id: ENV['AWS_ID'],
        secret_access_key: ENV['AWS_KEY']
      }
    }
  end
end
