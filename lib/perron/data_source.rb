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

      data.map.with_index do |item, index|
        unless item.is_a?(Hash)
          raise Errors::DataParseError, "Item at index #{index} in `#{@file_path}` must be a hash/object, got #{item.class}"
        end

        Item.new(item, identifier: @identifier)
      end
    end
    # def records
    #   content = rendered_from(@file_path)
    #   data = parsed_from(content, @file_path)

    #   unless data.is_a?(Array)
    #     raise Errors::DataParseError, "Data in `#{@file_path}` must be an array of objects."
    #   end

    #   data.map { Item.new(it, identifier: @identifier) }
    # end

    def rendered_from(path)
      raw_content = File.read(path)

      render_erb(raw_content)
    rescue NameError, ArgumentError, SyntaxError => error
      raise Errors::DataParseError, "Failed to render ERB in `#{path}`: (#{error.class}) #{error.message}"
    end

    def parsed_from(content, path)
      extension = File.extname(path)
      parser_method = PARSER_METHODS.fetch(extension) do
        raise Errors::UnsupportedDataFormatError, "Unsupported data format: #{extension}. Supported formats: #{SUPPORTED_EXTENSIONS.join(", ")}"
      end

      send(parser_method, content, path)
    end
    # def parsed_from(content, path)
    #   extension = File.extname(path)
    #   parser_method = PARSER_METHODS.fetch(extension) do
    #     raise Errors::UnsupportedDataFormatError, "Unsupported data format: #{extension}"
    #   end

    #   send(parser_method, content)
    # rescue Psych::SyntaxError, JSON::ParserError, CSV::MalformedCSVError => error
    #   raise Errors::DataParseError, "Failed to parse data format in `#{path}`: (#{error.class}) #{error.message}"
    # end

    def render_erb(content) = ERB.new(content).result(HelperContext.instance.get_binding)

    def parse_yaml(content, path)
      YAML.safe_load(content, permitted_classes: [Symbol, Time], aliases: true)
    rescue Psych::SyntaxError => error
      line_info = error.line ? " at line #{error.line}" : ""
      column_info = error.column ? ", column #{error.column}" : ""

      raise Errors::DataParseError, "Invalid YAML syntax in `#{path}`#{line_info}#{column_info}: #{error.problem}"
    end
    # def parse_yaml(content)
    #   YAML.safe_load(content, permitted_classes: [Symbol, Time], aliases: true)
    # end

    def parse_json(content, path)
      JSON.parse(content, symbolize_names: true)
    rescue JSON::ParserError => error
      line_match = error.message.match(/at line (\d+)/)
      line_info = line_match ? " at line #{line_match[1]}" : ""

      raise Errors::DataParseError, "Invalid JSON syntax in `#{path}`#{line_info}: #{error.message}"
    end
    # def parse_json(content)
    #   JSON.parse(content, symbolize_names: true)
    # end

    def parse_csv(content, path)
      expected_headers = nil

      CSV.new(content, headers: true, header_converters: :symbol).map.with_index do |row, index|
        expected_headers ||= row.headers

        if row.headers != expected_headers
          missing = expected_headers - row.headers
          extra = row.headers - expected_headers

          error_parts = []
          error_parts << "missing columns: #{missing.join(", ")}" if missing.any?
          error_parts << "extra columns: #{extra.join(", ")}" if extra.any?

          raise Errors::DataParseError, "Column mismatch in `#{path}` at row #{index + 2} (#{error_parts.join("; ")}). Expected: #{expected_headers.join(", ")}"
        end

        row.to_h
      end
    rescue CSV::MalformedCSVError => error
      line_match = error.message.match(/line (\d+)/)
      line_info = line_match ? " at line #{line_match[1]}" : ""

      raise Errors::DataParseError, "Malformed CSV in `#{path}`#{line_info}: #{error.message}"
    end
    # def parse_csv(content)
    #   CSV.new(content, headers: true, header_converters: :symbol).to_a.map(&:to_h)
    # end
  end
end
