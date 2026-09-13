# frozen_string_literal: true

module Perron
  class Collection
    attr_reader :name

    def initialize(name)
      @name = name.inquiry
      @collection_path = File.join(Perron.configuration.input, name)

      raise Errors::CollectionNotFoundError, "No such collection: #{name}" unless File.exist?(@collection_path) && File.directory?(@collection_path)
    end

    def configuration(resource_class = "Content::#{name.classify}".safe_constantize)
      resource_class&.configuration
    end

    def all(resource_class = "Content::#{name.classify}".safe_constantize)
      Perron::Relation.new(load_resources(resource_class).select(&:published?), resource_class)
    end
    alias_method :resources, :all

    def find(slug, resource_class = Resource)
      Perron.deprecator.deprecation_warning(
        :find,
        "Collection#find will return nil instead of raising in the next major version. Use #find! to raise an error."
      )

      find!(slug, resource_class)
    end

    def find!(slug, resource_class = Resource)
      resource = load_resources(resource_class).find { it.slug == slug }

      return resource if resource

      raise Errors::ResourceNotFoundError, "Resource not found with slug: #{slug}"
    end

    def find_by_file_name(file_name, resource_class = Resource)
      resource_class.new(
        Perron.configuration.allowed_extensions.lazy.map { File.join(collection_path, [file_name, it].join(".")) }.find { File.exist?(it) }
      )
    end

    def validate = Perron::Site::Validate.new(collections: [self]).validate

    def localized?
      Perron::Locales.available_locales.any? { File.directory?(File.join(@collection_path, it.to_s)) }
    end

    private

    def load_resources(resource_class = "Content::#{name.classify}".safe_constantize)
      allowed_extensions = Perron.configuration.allowed_extensions.map { ".#{it}" }.to_set
      locale_prefixes = available_locale_subdir_prefixes

      default_resources = Dir.glob("#{@collection_path}/**/*.*")
        .select { allowed_extensions.include?(File.extname(it)) }
        .reject { File.basename(it, ".*").downcase == "readme" }
        .reject { |path| locale_prefixes.any? { path.start_with?(it) } }
        .map { resource_class.new(it) }

      return default_resources if !localized? || I18n.locale == I18n.default_locale

      translation_paths = Dir.glob(File.join(@collection_path, I18n.locale.to_s, "**", "*.**"))
        .select { allowed_extensions.include?(File.extname(it)) }
        .reject { File.basename(it, ".*").downcase == "readme" }
        .map { resource_class.new(it) }

      translation_keys = translation_paths.map(&:translation_key)

      translation_paths + default_resources.reject { it.translation_key.in?(translation_keys) }
    end

    def collection_path
      locale_paths.find { File.directory?(it) } || @collection_path
    end

    def locale_paths
      [I18n.locale, I18n.default_locale].uniq.map { |locale| File.join(@collection_path, locale.to_s) }
    end

    def available_locale_subdir_prefixes
      Perron::Locales.available_locales
        .map { |locale| File.join(@collection_path, locale.to_s, "") }
        .select { File.directory?(it.chomp("/")) }
    end
  end
end
