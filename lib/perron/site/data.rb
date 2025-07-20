# frozen_string_literal: true

require "csv"

module Perron
  class Data < SimpleDelegator
    def initialize(identifier)
      @file_path = path_for(identifier)
      @records = records

      super(records)
    end

    private

    PARSER_METHODS = {
      ".yml" => :parse_yaml, ".yaml" => :parse_yaml,
      ".json" => :parse_json, ".csv" => :parse_csv
    }.freeze
    SUPPORTED_EXTENSIONS = PARSER_METHODS.keys

    def path_for(identifier)
      path = Pathname.new(identifier)

      return path.to_s if path.file? && path.absolute?

      path = SUPPORTED_EXTENSIONS.lazy.map { Rails.root.join("app", "content", "data").join("#{identifier}#{it}") }.find(&:exist?)
      path&.to_s or raise Errors::FileNotFoundError, "No data file found for '#{identifier}'"
    end

    def records
      content = File.read(@file_path)
      extension = File.extname(@file_path)
      parser = PARSER_METHODS.fetch(extension) do
        raise Errors::UnsupportedDataFormatError, "Unsupported data format: #{extension}"
      end

      data = send(parser, content)

      unless data.is_a?(Array)
        raise Errors::DataParseError, "Data in '#{@file_path}' must be an array of objects."
      end

      data.map { Item.new(it) }
    rescue Psych::SyntaxError, JSON::ParserError, CSV::MalformedCSVError => error
      raise Errors::DataParseError, "Failed to parse '#{@file_path}': #{error.message}"
    end

    def parse_yaml(content)
      YAML.safe_load(content, permitted_classes: [Symbol], aliases: true)
    end

    def parse_json(content)
      JSON.parse(content, symbolize_names: true)
    end

    def parse_csv(content)
      CSV.new(content, headers: true, header_converters: :symbol).to_a.map(&:to_h)
    end

    class Item
      def initialize(attributes)
        @attributes = attributes.transform_keys(&:to_sym)
      end

      def [](key) = @attributes[key.to_sym]

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

# require "csv"

# module Perron
#   class Data
#     include Enumerable

#     def initialize(resource)
#       @file_path = path_for(resource)
#       @data = data
#     end

#     def each(&block)
#       @data.each(&block)
#     end

#     private

#     PARSER_METHODS = {
#       ".csv" => :parse_csv,
#       ".json" => :parse_json,
#       ".yaml" => :parse_yaml,
#       ".yml" => :parse_yaml
#     }.freeze
#     SUPPORTED_EXTENSIONS = PARSER_METHODS.keys.freeze

#     def path_for(identifier)
#       path = Pathname.new(identifier)

#       return path.to_s if path.file? && path.absolute?

#       found_path = SUPPORTED_EXTENSIONS.lazy.map do |extension|
#         Rails.root.join("app", "content", "data").join("#{identifier}#{extension}")
#       end.find(&:exist?)

#       found_path&.to_s or raise Errors::FileNotFoundError, "No data file found for '#{identifier}'"
#     end

#     def data
#       content = File.read(@file_path)
#       extension = File.extname(@file_path)
#       parser = PARSER_METHODS.fetch(extension) do
#         raise Errors::UnsupportedDataFormatError, "Unsupported data format: #{extension}"
#       end

#       raw_data = send(parser, content)

#       unless raw_data.is_a?(Array)
#         raise Errors::DataParseError, "Data in '#{@file_path}' must be an array of objects."
#       end

#       struct = Struct.new(*raw_data.first.keys, keyword_init: true)
#       raw_data.map { struct.new(**it) }
#     rescue Psych::SyntaxError, JSON::ParserError, CSV::MalformedCSVError => error
#       raise Errors::DataParseError, "Failed to parse '#{@file_path}': #{error.message}"
#     end

#     def parse_yaml(content) = YAML.safe_load(content, permitted_classes: [Symbol], aliases: true)

#     def parse_json(content) = JSON.parse(content, symbolize_names: true)

#     def parse_csv(content) = CSV.new(content, headers: true, header_converters: :symbol).to_a.map(&:to_h)
#   end
# end
