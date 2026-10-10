# frozen_string_literal: true

module Perron
  class Resource
    class Separator
      attr_reader :content

      def initialize(content)
        parsed(content)
      end

      def frontmatter
        @frontmatter_with_dot_access ||= ActiveSupport::OrderedOptions.new.tap do |options|
          @frontmatter.each { |key, value| options[key] = value }
        end
      end

      private

      def parsed(content)
        if content =~ /\A---\s*(.*?)\s*---\s*(.*)/m
          parsed_yaml = YAML.safe_load($1, permitted_classes: [Date, Time])

          # A `---` at the start of the body (a thematic break) followed by
          # another `---` also matches, but parses to a string or an array
          # rather than a mapping. Only treat it as frontmatter when it is one.
          if parsed_yaml.nil? || parsed_yaml.is_a?(Hash)
            @frontmatter = parsed_yaml || {}
            @content = $2.strip

            return
          end
        end

        @frontmatter = {}
        @content = content
      end
    end
  end
end
