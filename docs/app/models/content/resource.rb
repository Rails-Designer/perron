class Content::Resource < Perron::Resource
  include Templates
  include Types

  source resource: { class: Content::Resource::Library, primary_key: :name }

  def self.source_template(source)
    source.resource.content
  end

  search_fields :description, :category, :collection_name

  delegate :title, :description, :category, :command, to: :metadata
  alias_method :name, :title

  validates :title, :description, presence: true

  def images
    base_path = Rails.root.join("app", "content", "resources", slug, "images")

    Dir.glob(File.join(base_path, "**", "*"))
      .reject { File.directory?(it) || it =~ /\.+$/ }
      .map { it.delete_prefix("#{base_path}/") }
  end

  def position = metadata.position || Float::INFINITY

  def collection_name = "Library"
end
