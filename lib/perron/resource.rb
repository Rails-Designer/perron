# frozen_string_literal: true

require "perron/resource/configuration"
require "perron/resource/core"
require "perron/resource/class_methods"
require "perron/resource/metadata"
require "perron/resource/publishable"
require "perron/resource/reading_time"
require "perron/resource/related"
require "perron/resource/renderer"
require "perron/resource/slug"
require "perron/resource/separator"
require "perron/resource/table_of_content"

module Perron
  class Resource
    ID_LENGTH = 8

    include ActiveModel::Validations

    include Perron::Resource::Configuration
    include Perron::Resource::Core
    include Perron::Resource::ClassMethods
    include Perron::Resource::ReadingTime
    include Perron::Resource::Publishable
    include Perron::Resource::TableOfContent

    attr_reader :file_path, :id

    def initialize(file_path)
      @errors = ActiveModel::Errors.new(self)
      @file_path = file_path
      @id = generate_id

      raise Errors::FileNotFoundError, "No such file: #{file_path}" unless File.exist?(file_path)
    end

    def filename = File.basename(@file_path)

    def slug = Perron::Resource::Slug.new(self, frontmatter).create
    alias_method :path, :slug
    alias_method :to_param, :slug

    def metadata
      Perron::Resource::Metadata.new(
        resource: self,
        frontmatter: frontmatter,
        collection: collection
      ).data
    end

    def raw_content = File.read(@file_path)
    alias_method :raw, :raw_content

    def content
      page_content = Perron::Resource::Separator.new(raw_content).content

      return Perron::Resource::Renderer.erb(page_content, resource: self) if erb_processing?

      render_inline_erb using: page_content
    end

    def to_partial_path
      @to_partial_path ||= begin
        element = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(self.class.model_name))
        collection = ActiveSupport::Inflector.tableize(self.class.model_name)

        File.join("content", collection, element)
      end
    end

    def collection = Collection.new(self.class.model_name.collection)

    def related_resources(limit: 5) = Perron::Site::Resource::Related.new(self).find(limit:)
    alias_method :related, :related_resources

    private

    def frontmatter
      @frontmatter ||= Perron::Resource::Separator.new(raw_content).frontmatter
    end

    def generate_id
      Digest::SHA1.hexdigest(
        @file_path.delete_prefix(Perron.configuration.input.to_s).parameterize
      ).first(ID_LENGTH)
    end

    def render_inline_erb(using:)
      using.gsub(/<%=\s*erbify\s+do\s*%>(.*?)<%\s*end\s*%>/m) do
        Perron::Resource::Renderer.erb(Regexp.last_match(1).strip_heredoc, resource: self)
      end
    end

    def erb_processing?
      @file_path.ends_with?(".erb") || metadata.erb == true
    end

    def root?
      collection.name.inquiry.pages? && File.basename(filename) == "root"
    end
  end
end
