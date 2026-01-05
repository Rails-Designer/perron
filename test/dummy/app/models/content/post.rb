class Content::Post < Perron::Resource
  belongs_to :author
  belongs_to :editor, class_name: "Content::Data::Editors"

  configure do |config|
    config.sitemap.enabled = false

    config.metadata.author = "The Post Collection Team"
    config.metadata.type = "article"
  end
end
