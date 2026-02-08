class Content::Post < Perron::Resource
  configure do |config|
    config.sitemap.enabled = false

    config.feeds.rss.author = {
      name: "RSS Config Author",
      email: "support@railsdesigner.com"
    }

    config.feeds.json.author = {
      name: "JSON Config Author",
      email: "support@railsdesigner.com"
    }

    config.metadata.author = "The Post Collection Team"
    config.metadata.type = "article"
  end

  belongs_to :author
  belongs_to :editor, class_name: "Content::Data::Editors"

  delegate :title, to: :metadata

  scope :ordered, -> { order(:slug) }
  scope :limited, -> { limit(2) }
end
