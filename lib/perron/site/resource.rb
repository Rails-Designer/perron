# frozen_string_literal: true

require "perron/site/resource/configuration"
require "perron/site/resource/core"
require "perron/site/resource/class_methods"
require "perron/site/resource/publishable"
require "perron/site/resource/related"
require "perron/site/resource/slug"
require "perron/site/resource/separator"

module Perron
  class Resource
    ID_LENGTH = 8

    include Perron::Resource::Configuration
    include Perron::Resource::Core
    include Perron::Resource::ClassMethods
    include Perron::Resource::Publishable

    attr_reader :file_path, :id

    def initialize(file_path)
      @file_path = file_path
      @id = generate_id

      raise Errors::FileNotFoundError, "No such file: #{file_path}" unless File.exist?(file_path)
    end

    def filename = File.basename(@file_path)

    def slug = Perron::Resource::Slug.new(self).create
    alias_method :path, :slug
    alias_method :to_param, :slug

    def content
      return Perron::Resource::Separator.new(raw_content).content unless processable?

      ::ApplicationController
        .renderer
        .render(
          inline: Perron::Resource::Separator.new(raw_content).content,
          assigns: {resource: self}
        )
    end

    def metadata = Perron::Resource::Separator.new(raw_content).metadata

    def raw_content = File.read(@file_path)
    alias_method :raw, :raw_content

    def collection = Collection.new(self.class.model_name.collection)

    def related_resources(limit: 5) = Perron::Site::Resource::Related.new(self).find(limit:)
    alias_method :related, :related_resources

    private

    def processable?
      @file_path.ends_with?(".erb") || metadata.erb == true
    end

    def generate_id
      Digest::SHA1.hexdigest(
        @file_path.delete_prefix(Perron.configuration.input.to_s).parameterize
      ).first(ID_LENGTH)
    end
  end
end
