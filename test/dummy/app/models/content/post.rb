class Content::Post < Perron::Resource
  configure do |config|
    config.sitemap.enabled = false
  end
end
