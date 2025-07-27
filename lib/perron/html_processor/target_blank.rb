# frozen_string_literal: true

require "perron/html_processor/base"

module Perron
  class HtmlProcessor
    class TargetBlank < HtmlProcessor::Base
      def process
        @html.css("a").each do |link|
          href = link["href"]

          next if href.blank? || href.start_with?("/", "#", "mailto:")

          link["target"] = "_blank"
        end
      end
    end
  end
end
