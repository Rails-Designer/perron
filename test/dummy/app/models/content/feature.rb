class Content::Feature < Perron::Resource
  configure do |config|
    config.sitemap.enabled = false
  end
end
