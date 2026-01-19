# frozen_string_literal: true

require "rails/generators/base"

module Rails
  module Generators
    class ContentGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :force_plural, type: :boolean, default: false, desc: "Forces the use of a plural model name and class"
      class_option :include_root, type: :boolean, default: nil, desc: "Include root action and route (defaults to true for pages)"
      class_option :new, type: :string, default: nil, banner: "TITLE",
        desc: "Create a new content file from template instead of generating scaffold"
      class_option :data, type: :array, default: [], banner: "source1(.ext) source2(.ext)",
        desc: "Specify data sources with optional extensions (defaults to .yml)"

      argument :actions, type: :array, default: %w[index show], banner: "actions", desc: "Specify which actions to generate (index/show)"

      def initialize(*args)
        super

        @content_mode = !options[:new].nil?
        @content_title = options[:new].presence
      end

      def create_content_file
        return unless @content_mode

        @title = @content_title

        if template_file
          create_file File.join(content_directory, filename_from_template), ERB.new(File.read(template_file)).result(binding)
        else
          create_file File.join(content_directory, filename_from_template), "---\n---\n"
        end
      end

      def create_model
        return if @content_mode

        template "model.rb.tt", File.join("app/models/content", "#{file_name}.rb")
      end

      def create_controller
        return if @content_mode

        template "controller.rb.tt", File.join("app/controllers/content", "#{plural_file_name}_controller.rb")
      end

      def create_views
        return if @content_mode

        empty_directory view_directory

        actions.each do |action|
          template "#{action}.html.erb.tt", File.join(view_directory, "#{action}.html.erb")
        end
      end

      def create_content_directory
        return if @content_mode

        FileUtils.mkdir_p(content_directory)
      end

      def add_content_route
        return if @content_mode

        route "resources :#{plural_file_name}, module: :content, only: %w[#{actions.join(" ")}]"
      end

      def create_data_sources
        return if @content_mode
        return if options[:data].empty?

        options[:data].each do |source|
          name, extension = source.split(".", 2)

          create_file File.join(content_directory, "#{name}.#{extension || "yml"}"), ""
        end
      end

      def add_root_action
        return if @content_mode
        return unless should_include_root?

        inject_into_class "app/controllers/content/#{plural_file_name}_controller.rb", "Content::#{plural_class_name}Controller" do
          <<-RUBY

        def root
          @resource = Content::#{class_name}.root

          render :show
        end
          RUBY
        end
      end

      def create_root_content_file
        return if @content_mode
        return unless should_include_root?

        template "root.erb.tt", File.join(content_directory, "root.erb")
      end

      def add_root_route
        return if @content_mode
        return unless should_include_root?
        return if root_route_exists?

        route "root to: \"content/#{plural_file_name}#root\""
      end

      private

      def file_name
        options[:force_plural] ? super.pluralize : super.singularize
      end

      def class_name
        options[:force_plural] ? super.pluralize : super.singularize
      end

      def view_directory = File.join(destination_root, "app", "views", "content", plural_file_name)

      def content_directory = File.join(destination_root, "app", "content", plural_file_name)

      def plural_class_name = plural_name.camelize

      def pages_controller? = plural_file_name == "pages"

      def template_file
        @template_file ||= Dir.glob(File.join(content_directory, "{YYYY-MM-DD-,}template.*.tt")).first
      end

      def filename_from_template
        @filename_from_template ||= begin
          return "untitled.md" unless template_file

          File.basename(template_file, ".tt").tap do |name|
            name.gsub!("YYYY-MM-DD", Time.current.strftime("%Y-%m-%d"))
            name.sub!("template", @content_title ? @content_title.parameterize : "untitled")
          end
        end
      end

      def should_include_root?
        options[:include_root].nil? ? pages_controller? : options[:include_root]
      end

      def root_route_exists?
        routes = File.join(destination_root, "config", "routes.rb")
        return false unless File.exist?(routes)

        File.read(routes).match?(/\broot\s+to:/)
      end

      def data_sources
        options[:data].map { it.split(".").first }
      end

      def data_sources? = !options[:data].empty?
    end
  end
end
