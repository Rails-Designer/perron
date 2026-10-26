module Content::Resource::Templates
  extend ActiveSupport::Concern

  def template = ERB.new(File.read(template_path)).result(binding)

  def template_files
    base_path = Rails.root.join("app", "content", "resources", slug, "template_files")

    Dir.glob(File.join(base_path, "**", "*"))
      .reject { File.directory?(it) || it =~ /\.+$/ }
      .map { [ it.delete_prefix("#{base_path}/").delete_suffix(".tt"), it ] }
  end

  private

  def template_path = Rails.root.join("app", "content", "resources", slug, "template.rb")
end
