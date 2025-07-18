# frozen_string_literal: true

module Perron
  class HtmlProcessor
    class TargetBlank
      def initialize(html)
        @html = html
      end

      def process
        @html.css("a").each do |link|
          href = link["href"]

          next unless href
          next if href.start_with?("/", "#", "mailto:")

          link["target"] = "_blank"
          link["rel"] = "noopener"
        end
      end
    end
  end
end
