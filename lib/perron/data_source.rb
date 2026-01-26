# frozen_string_literal: true

require "csv"

require "perron/data_source/class_methods"
require "perron/data_source/item"
require "perron/data_source/helper_context"

module Perron
  class DataSource < SimpleDelegator
    include Enumerable

    include Perron::DataSource::ClassMethods

    def initialize(identifier)
      @identifier = identifier
      @file_path = self.class.path_for!(identifier)
      @records = records

      super(records)
    end

    def each(&block) = @records.each(&block)

    def count = @records.count

    def first(n = nil)
      n ? @records.first(n) : @records.first
    end

    def last = @records.last

    def [](index) = @records[index]

    def size = @records.size
    alias_method :length, :size

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
  end
end
