# frozen_string_literal: true

require "perron/html_processor/target_blank"
require "perron/html_processor/lazy_load_images"
require "perron/html_processor/absolute_urls"

module Perron
  class HtmlProcessor
    def initialize(html, processors: [], resource: nil)
      @html = html
      @resource = resource
      @processors = processors.map { find_by(it) }
    end

    def process
      Nokogiri::HTML::DocumentFragment.parse(@html).tap do |document|
        @processors.each { it.new(document, resource: @resource).process }
      end.to_html
    end

    private

    BUILT_IN = {
      "target_blank" => Perron::HtmlProcessor::TargetBlank,
      "lazy_load_images" => Perron::HtmlProcessor::LazyLoadImages,
      "absolute_urls" => Perron::HtmlProcessor::AbsoluteUrls
    }

    def find_by(identifier)
      case identifier
      when String, Symbol
        key = identifier.to_s

        BUILT_IN[key] || find_class_by(key)
      when Class
        identifier
      else
        raise Perron::Errors::InvalidProcessorError, "Processor must be a String, Symbol, or Class, but got #{identifier.class.name}."
      end
    end

    def find_class_by(name)
      processor = name.camelize.safe_constantize

      return processor if processor

      raise Perron::Errors::ProcessorNotFoundError, "Could not find processor `#{name}`. It is not a Perron-included processor and the constant `#{name.camelize}` could not be found."
    end
  end
end
