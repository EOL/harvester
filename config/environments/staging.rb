Rails.application.configure do
  config.cache_classes = true
  cache_addr = ENV['EOL_STAGING_CACHE_URL'] || 'memcached:11211'
  config.cache_store = :mem_cache_store, cache_addr, { namespace: 'harvester', compress: true }
  config.lograge.ignore_actions = ['ResourcesController#ping', 'ResourcesController#index']
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.action_dispatch.default_headers = { 'X-Frame-Options' => 'ALLOWALL' }
  # TODO: set up mailing...
  config.action_mailer.default_url_options = { host: 'content.eol.org', port: 3000 }
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'content.eol.org', port: 1025}
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = false
  config.assets.digest = true
  config.assets.raise_runtime_errors = true
  config.default_host = 'http://content.eol.org'
end
