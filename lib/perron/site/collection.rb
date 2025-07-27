# frozen_string_literal: true

module Perron
  class Collection
    attr_reader :name

    def initialize(name)
      @name = name
      @collection_path = File.join(Perron.configuration.input, name)

      raise Errors::CollectionNotFoundError, "No such collection: #{name}" unless File.exist?(@collection_path) && File.directory?(@collection_path)
    end

    def configuration(resource_class = "Content::#{name.classify}".safe_constantize)
      resource_class.configuration
    end

    def all(resource_class = "Content::#{name.classify}".safe_constantize)
      @all ||= Dir.glob("#{@collection_path}/**/*.*").map do |file_path|
        resource_class.new(file_path)
      end.select(&:published?)
    end
    alias_method :resources, :all

    def find(slug, resource_class = Resource)
      resource = all(resource_class).find { it.slug == slug }

      return resource if resource

      raise Errors::ResourceNotFoundError, "Resource not found with slug: #{slug}"
    end
  end
end
