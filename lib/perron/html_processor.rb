# frozen_string_literal: true

require "perron/html_processor/target_blank"

module Perron
  class HtmlProcessor
    def initialize(html)
      @html = html
    end

    def process
      document = Nokogiri::HTML::DocumentFragment.parse(@html)

      PROCESSORS.each do |processor|
        processor.new(document).process
      end

      document.to_html
    end

    private

    # TODO: should be a configuration option
    PROCESSORS = [
      Perron::HtmlProcessor::TargetBlank
    ]
  end
end
