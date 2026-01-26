# frozen_string_literal: true

module Perron
  class Resource
    module Sweeper
      extend ActiveSupport::Concern

      def extracted_headings
        extract_heading_texts(from: rendered_document)
      end

      def sweeped_content
        ActionView::Base.full_sanitizer.sanitize(
          rendered_document.text.gsub(/\s+/, " ").strip
        )
      end

      private

      def rendered_document
        @rendered_document ||= Nokogiri::HTML::DocumentFragment.parse(Markdown.render(content))
      end

      def extract_heading_texts(from:, levels: "h1, h2, h3, h4, h5, h6")
        from.css(levels).map { it.text.strip }.compact_blank
      end

      def extract_headings(from:, levels:)
        from.css(levels).each_with_object([]) do |heading, headings|
          heading_text = heading.text.strip
          id = heading["id"] || heading.at("a")&.[]("id")

          next if heading_text.empty? || id.blank?

          headings << TableOfContent::Item.new(
            id: id,
            text: heading_text,
            level: heading.name[1..].to_i,
            children: []
          )
        end
      end
    end
  end
end
