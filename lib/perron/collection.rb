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
      Perron::Relation.new(load_resources(resource_class).select(&:published?))
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
        Perron.configuration.allowed_extensions.lazy.map { File.join(@collection_path, [file_name, it].join(".")) }.find { File.exist?(it) }
      )
    end

    def validate = Perron::Site::Validate.new(collections: [self]).validate

    private

    def load_resources(resource_class = "Content::#{name.classify}".safe_constantize, locale: I18n.locale.to_s)
      allowed_extensions = Perron.configuration.allowed_extensions.map { ".#{it}" }.to_set

      Dir.glob("#{collection_path}/**/*.*")
        .select { allowed_extensions.include?(File.extname(it)) }
        .map { resource_class.new(it) }
    end

    def collection_path
      locale_path = "#{@collection_path}/#{I18n.locale.to_s}"

      Dir.exist?(locale_path) ? locale_path : @collection_path
    end
  end
end
