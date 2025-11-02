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
        return unless (c = Perron.configuration.markdown_parser)
        const = c.to_s.camelize
        klass = find_class(const) || find_class(const + "Parser")

        unless klass
          raise "Can't find parser #{c}"
        end

        unless klass.avail?
          raise "Parser #{c} #{const} is not available (gem not installed?)"
        end

        klass
      end

      def find_class(const)
        if Object.const_defined?(const)
          Object.const_get(const)
        elsif const_defined?(const)
          const_get(const)
        end
      end

      def available_parser = Parser.descendants.filter(&:avail?).first || Parser

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

      def self.avail? = true
    end

    class RedcarpetParser < Parser
      def renderer
        @renderer ||= Redcarpet::Render::HTML.new(options.fetch(:renderer_options, {}))
      end

      def markdown
        @markdown ||= Redcarpet::Markdown.new(renderer, options.fetch(:markdown_options, {}))
      end

      def parse(text) = markdown.render(text)

      def self.avail? = defined?(::Redcarpet)
    end

    class KramdownParser < Parser
      def parse(text) = Kramdown::Document.new(text, options).to_html

      def self.avail? = defined?(::Kramdown)
    end

    class CommonMarkerParser < Parser
      def parse(text) = Commonmarker.to_html(text, **options)

      def self.avail? = defined?(::Commonmarker)
    end
  end
end
