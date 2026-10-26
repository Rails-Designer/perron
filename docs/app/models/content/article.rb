class Content::Article < Perron::Resource
  include Sections

  delegate :section, :position, :title, :description, to: :metadata

  adjacent_by :position, within: { section: SECTIONS.keys }

  search_fields :description, :collection_name

  validates :title, :description, presence: true
  validates :section, inclusion: { in: SECTIONS.keys }
  validates :position, numericality: { greater_than_or_equal_to: 1 }

  def collection_name = "Docs"
end
