# frozen_string_literal: true

require "csv"

module Perron
  class Data < SimpleDelegator
    def initialize(identifier)
      @identifier = identifier
      @file_path = self.class.path_for!(identifier)
      @records = records

      super(records)
    end

    class << self
      def path_for(identifier)
        path = Pathname.new(identifier)

        return path.to_s if path.file? && path.absolute?

        base_path = Rails.root.join("app", "content", "data")

        SUPPORTED_EXTENSIONS.lazy.map { base_path.join("#{identifier}#{it}") }.find(&:exist?)&.to_s
      end

      def path_for!(identifier)
        path_for(identifier).tap do |path|
          raise Errors::FileNotFoundError, "No data file found for `#{identifier}`" unless path
        end
      end

      def directory?(identifier) = Dir.exist?(Rails.root.join("app", "content", "data", identifier))
    end

    private

    PARSER_METHODS = {
      ".yml" => :parse_yaml, ".yaml" => :parse_yaml,
      ".json" => :parse_json, ".csv" => :parse_csv
    }.freeze
    SUPPORTED_EXTENSIONS = PARSER_METHODS.keys

    def records
      content = rendered_from(@file_path)
      data = parsed_from(content, @file_path)

      unless data.is_a?(Array)
        raise Errors::DataParseError, "Data in `#{@file_path}` must be an array of objects."
      end

      data.map { Item.new(it, identifier: @identifier) }
    end

    def rendered_from(path)
      raw_content = File.read(path)

      render_erb(raw_content)
    rescue NameError, ArgumentError, SyntaxError => error
      raise Errors::DataParseError, "Failed to render ERB in `#{path}`: (#{error.class}) #{error.message}"
    end

    def parsed_from(content, path)
      extension = File.extname(path)
      parser_method = PARSER_METHODS.fetch(extension) do
        raise Errors::UnsupportedDataFormatError, "Unsupported data format: #{extension}"
      end

      send(parser_method, content)
    rescue Psych::SyntaxError, JSON::ParserError, CSV::MalformedCSVError => error
      raise Errors::DataParseError, "Failed to parse data format in `#{path}`: (#{error.class}) #{error.message}"
    end

    def render_erb(content) = ERB.new(content).result(HelperContext.instance.get_binding)

    def parse_yaml(content)
      YAML.safe_load(content, permitted_classes: [Symbol, Time], aliases: true)
    end

    def parse_json(content)
      JSON.parse(content, symbolize_names: true)
    end

    def parse_csv(content)
      CSV.new(content, headers: true, header_converters: :symbol).to_a.map(&:to_h)
    end

    class HelperContext
      include Singleton

      def initialize
        self.class.include ActionView::Helpers::AssetUrlHelper
        self.class.include ActionView::Helpers::DateHelper
        self.class.include Rails.application.routes.url_helpers
      end

      def get_binding = binding
    end
    private_constant :HelperContext

    class Item
      def initialize(attributes, identifier:)
        @attributes = attributes.transform_keys(&:to_sym)
        @identifier = identifier
      end

      def [](key) = @attributes[key.to_sym]

      def to_partial_path
        identifier = @identifier.to_s
        collection_path = File.extname(identifier).present? ? File.basename(identifier, ".*") : identifier
        item = collection_path.split("/").last.singularize

        File.join("content", collection_path, item)
      end

      def method_missing(method_name, *arguments, &block)
        return super if !@attributes.key?(method_name) || arguments.any? || block

        @attributes[method_name]
      end

      def respond_to_missing?(method_name, include_private = false)
        @attributes.key?(method_name) || super
      end
    end
    private_constant :Item
  end
end
