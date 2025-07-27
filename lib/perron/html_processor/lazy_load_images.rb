# frozen_string_literal: true

module Perron
  class HtmlProcessor
    class LazyLoadImages < HtmlProcessor::Base
      def process
        @html.css("img").each do |image|
          image["loading"] = "lazy"
        end
      end
    end
  end
end
