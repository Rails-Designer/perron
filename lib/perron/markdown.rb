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
        if defined?(::CommonMarker)
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
      def parse(text) = CommonMarker.render_html(text, :DEFAULT)
    end

    class KramdownParser
      def parse(text) = Kramdown::Document.new(text).to_html
    end

    class RedcarpetParser
      def parse(text)
        renderer = Redcarpet::Render::HTML.new(filter_html: true)
        markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true)

        markdown.render(text)
      end
    end

    class PlainTextParser
      def parse(text) = text.to_s
    end
  end
end
