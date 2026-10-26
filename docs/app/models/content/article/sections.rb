module Content::Article::Sections
  extend ActiveSupport::Concern

  SECTIONS = {
    getting_started: "Getting started",
    content: "Content",
    render: "Render",
    meta: "Meta"
  }.with_indifferent_access

  class_methods do
    def sections
      SECTIONS.map do |key, name|
        Section.new(
          key: key,
          name: name,
          resources: where(section: key).order(:position)
        )
      end
    end
  end

  included do
    scope :by_section, -> { sort_by { [ Content::Article::SECTIONS.keys.index(it.section), it.position ] } }
  end

  def article_section
    Section.new(
      key: metadata.section,
      name: SECTIONS[metadata.section],
      resources: self.class.where(section: metadata.section).order(:position)
    )
  end

  private

  Section = Data.define(:key, :name, :resources)
end
