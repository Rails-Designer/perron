# frozen_string_literal: true

module Perron
  class Resource
    class Separator
      attr_reader :content

      def initialize(content)
        parsed(content)
      end

      def metadata
        @metadata_with_dot_access ||= ActiveSupport::OrderedOptions.new.tap do |options|
          @metadata.each { |key, value| options[key] = value }
        end
      end

      private

      def parsed(content)
        if content =~ /\A---\s*(.*?)\s*---\s*(.*)/m
          @metadata = YAML.safe_load($1, permitted_classes: [Date, Time]) || {}
          @content = $2.strip
        else
          @metadata = {}
          @content = content
        end
      end
    end
  end
end
