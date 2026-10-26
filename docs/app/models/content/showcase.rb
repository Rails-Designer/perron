class Content::Showcase < Perron::Resource
  delegate :title, :description, :image, :url, to: :metadata

  scope :recently_published, -> {order(published_at: :desc)}
end
