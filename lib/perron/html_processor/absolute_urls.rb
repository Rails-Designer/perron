# frozen_string_literal: true

module Perron
  class HtmlProcessor
    class AbsoluteUrls < HtmlProcessor::Base
      def process
        @html.css("img").each do |image|
          src = image["src"]

          next if src.blank? || absolute_url?(src)

          image["src"] = base_url + src
        end
      end

      private

      def absolute_url?(src)
        src.start_with?("http://", "https://", "//")
      end

      def base_url
        Perron.configuration.url.delete_suffix("/")
      end
    end
  end
end
