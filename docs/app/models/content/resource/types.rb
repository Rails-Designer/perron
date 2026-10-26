module Content::Resource::Types
  extend ActiveSupport::Concern

  included do
    scope :by_type, ->(type) { where(type: type) }

    validates :type, inclusion: { in: TYPES.keys }
  end

  ICONS = {
    component: "puzzle-piece",
    snippet: "code-simple",
    template: "browser"
  }.with_indifferent_access

  TYPES = {
    component: "Components",
    snippet: "Snippets",
    template: "Templates"
  }.with_indifferent_access

  DESCRIPTIONS = {
    template: "Complete HTML templates for pages, site sections and full websites",
    snippet: "Code snippets to inject functionality into your site",
    component: "Static site specific UI components"
  }.with_indifferent_access


  def resource_type
    Type.new(name: TYPES[metadata.type], description: DESCRIPTIONS[metadata.type], slug: TYPES[metadata.type].parameterize)
  end
  alias_method :article_section, :resource_type # required for a consistent API with Content::Article

  def type = metadata.type.inquiry

  private

  Type = Data.define(:name, :description, :slug)
end
