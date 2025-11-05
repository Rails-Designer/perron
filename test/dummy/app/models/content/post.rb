class Content::Post < Perron::Resource
  belongs_to :author

  configure do |config|
    config.sitemap.enabled = false

    config.metadata.author = "The Post Collection Team"
    config.metadata.type = "article"
  end
end
