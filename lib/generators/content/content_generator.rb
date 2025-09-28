# frozen_string_literal: true

require "rails/generators/base"

class ContentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  class_option :force_plural, type: :boolean, default: false, desc: "Forces the use of a plural model name and class"

  argument :actions, type: :array, default: %w[index show], banner: "actions", desc: "Specify which actions to generate (index/show)"

  def create_model
    template "model.rb.tt", File.join("app/models/content", "#{file_name}.rb")
  end

  def create_controller
    template "controller.rb.tt", File.join("app/controllers/content", "#{plural_file_name}_controller.rb")
  end

  def create_views
    empty_directory view_directory

    actions.each do |action|
      template "#{action}.html.erb.tt", File.join(view_directory, "#{action}.html.erb")
    end
  end

  def create_content_directory = FileUtils.mkdir_p(content_directory)

  def create_pages_root
    return unless pages_controller?

    template "root.erb.tt", File.join(content_directory, "root.erb")
  end

  def add_content_route
    route "resources :#{plural_file_name}, module: :content, only: %w[#{actions.join(" ")}]"
  end

  def add_root_route
    return unless pages_controller?
    return if root_route_exists?

    inject_into_file "config/routes.rb", "  root to: \"content/pages#show\"\n", before: /^\s*end\s*$/
  end

  private

  def file_name
    options[:force_plural] ? super.pluralize : super.singularize
  end

  def class_name
    options[:force_plural] ? super.pluralize : super.singularize
  end

  def view_directory = Rails.root.join("app", "views", "content", plural_file_name)

  def content_directory = Rails.root.join("app", "content", plural_file_name)

  def plural_class_name = plural_name.camelize

  def pages_controller? = plural_file_name == "pages"

  def root_route_exists?
    routes = Rails.root.join("config", "routes.rb")

    return false unless File.exist?(routes)

    File.read(routes).match?(/\broot\s+to:/)
  end
end
