# frozen_string_literal: true

require "perron/html_processor"

module Perron
  class Markdown
    class << self
      def render(text, processors: [])
        parser.parse(text)
          .then { Perron::HtmlProcessor.new(it, processors: processors).process }
          .html_safe
      end

      private

      def parser
        @parser ||= markdown_parser
      end

      def configured_parser
        return unless (parser_name = Perron.configuration.markdown_parser)
        class_name = parser_name.to_s.camelize
        class_name += "Parser" unless class_name.end_with?("Parser")

        klass = if const_defined?(class_name)
          const_get(class_name)
        elsif Object.const_defined?(class_name)
          Object.const_get(class_name)
        else
          raise "Can't find parser #{parser_name} by class name #{class_name}"
        end

        unless klass.available?
          raise "Parser #{parser_name} #{class_name} is not available (gem not installed?)"
        end

        klass
      end

      def available_parser = Parser.descendants.find(&:available?) || Parser

      def markdown_parser
        (configured_parser || available_parser).new(**Perron.configuration.markdown_options)
      end
    end

    class Parser
      attr_reader :options

      def initialize(**options)
        @options = options
      end

      def parse(text) = text.to_s

      def self.available? = true
    end

    class RedcarpetParser < Parser
      def renderer
        @renderer ||= Redcarpet::Render::HTML.new(options.fetch(:renderer_options, {}))
      end

      def markdown
        @markdown ||= Redcarpet::Markdown.new(renderer, options.fetch(:markdown_options, {}))
      end

      def parse(text) = markdown.render(text)

      def self.available? = defined?(::Redcarpet)
    end

    class KramdownParser < Parser
      def parse(text) = Kramdown::Document.new(text, options).to_html

      def self.available? = defined?(::Kramdown)
    end

    class CommonMarkerParser < Parser
      def parse(text) = Commonmarker.to_html(text, **options)

      def self.available? = defined?(::Commonmarker)
    end
  end
end
