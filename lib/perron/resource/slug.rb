# frozen_string_literal: true

require "perron/refinements/delete_suffixes"

module Perron
  class Resource
    class Slug
      using Perron::SuffixStripping

      def initialize(resource, frontmatter)
        @resource = resource
        @frontmatter = frontmatter
      end

      def create
        @frontmatter.slug.presence ||
          @resource.filename.sub(/^[\d-]+-/, "").delete_suffixes(dot_prepended_allowed_extensions)
      end

      private

      def dot_prepended_allowed_extensions = Perron.configuration.allowed_extensions.map { ".#{it}" }
    end
  end
end
