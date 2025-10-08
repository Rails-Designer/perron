class Content::Page < Perron::Resource
  delegate :title, :description, to: :metadata

  validates :description, presence: true
end
