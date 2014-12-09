AssetKeeper::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false


  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log


  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Setup precompiling of assets. Normally set to false for development
  # but enable it for debugging production issues in development
  # config.assets.enabled = false

  # Settings for email
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true

	config.action_mailer.smtp_settings = {
  	:address              => ENV["SMTP_HOST"],
		:port                 => ENV["SMTP_PORT"],
		:domain               => ENV["SMTP_DOMAIN"],
		:user_name            => ENV["SMTP_USER"],
		:password             => ENV["SMTP_PASSWORD"],
    :authentication       => :plain,
#		:enable_starttls_auto => true
  }
end
