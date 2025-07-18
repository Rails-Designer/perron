# frozen_string_literal: true

module Perron
  class Collection
    attr_reader :name

    def initialize(name)
      @name = name
      @collection_path = File.join(Rails.root, Perron.configuration.input, name)

      raise Errors::CollectionNotFoundError, "No such collection: #{name}" unless File.exist?(@collection_path) && File.directory?(@collection_path)
    end

    def all(resource_class = "Content::#{name.classify}".safe_constantize)
      @all ||= Dir.glob("#{@collection_path}/**/*.*").map do |file_path|
        resource_class.new(file_path)
      end.select(&:published?)
    end

    def find(slug, resource_class = Resource)
      resource = all(resource_class).find { it.slug == slug }

      return resource if resource

      raise Errors::ResourceNotFoundError, "Resource not found with slug: #{slug}"
    end
  end
end
