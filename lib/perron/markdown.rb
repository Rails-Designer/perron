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

      def markdown_parser
        if defined?(::Commonmarker)
          CommonMarkerParser.new
        elsif defined?(::Kramdown)
          KramdownParser.new
        elsif defined?(::Redcarpet)
          RedcarpetParser.new
        else
          PlainTextParser.new
        end
      end
    end

    class CommonMarkerParser
      def parse(text) = Commonmarker.to_html(text, **Perron.configuration.markdown_options)
    end

    class KramdownParser
      def parse(text) = Kramdown::Document.new(text, Perron.configuration.markdown_options).to_html
    end

    class RedcarpetParser
      def parse(text)
        options = Perron.configuration.markdown_options
        renderer = Redcarpet::Render::HTML.new(options.fetch(:renderer_options, {}))
        markdown = Redcarpet::Markdown.new(renderer, options.fetch(:markdown_options, {}))

        markdown.render(text)
      end
    end

    class PlainTextParser
      def parse(text) = text.to_s
    end
  end
end
