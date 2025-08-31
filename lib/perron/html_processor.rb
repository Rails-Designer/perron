# frozen_string_literal: true

require "perron/html_processor/target_blank"
require "perron/html_processor/lazy_load_images"

module Perron
  class HtmlProcessor
    def initialize(html, processors: [])
      @html = html
      @processors = processors.map { find_by(it) }
    end

    def process
      Nokogiri::HTML::DocumentFragment.parse(@html).tap do |document|
        @processors.each { it.new(document).process }
      end.to_html
    end

    private

    BUILT_IN = {
      "target_blank" => Perron::HtmlProcessor::TargetBlank,
      "lazy_load_images" => Perron::HtmlProcessor::LazyLoadImages
    }.tap do |processors|
      require "rouge"
      require "perron/html_processor/syntax_highlight"

      processors["syntax_highlight"] = Perron::HtmlProcessor::SyntaxHighlight
    rescue LoadError
    end

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

      raise Perron::Errors::ProcessorNotFoundError, "The `syntax_highlight` processor requires `rouge`. Run `bundle add rouge` to add it to your Gemfile." if name.inquiry.syntax_highlight?
      raise Perron::Errors::ProcessorNotFoundError, "Could not find processor `#{name}`. It is not a Perron-included processor and the constant `#{name.camelize}` could not be found."
    end
  end
end
