Perron.configure do |config|
  config.input = "test/dummy/app/content"
  config.site_name = "Dummy App"

  config.search_scope = %w[post non_existing]
end
