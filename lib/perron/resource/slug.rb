# frozen_string_literal: true

require "perron/refinements/delete_suffixes"

module Perron
  class Resource
    class Slug
      using Perron::Refinements::DeleteSuffixes

      def initialize(resource, frontmatter)
        @resource = resource
        @frontmatter = frontmatter
      end

      def create
        return "/" if Perron.configuration.allowed_extensions.any? { @resource.filename == "root.#{it}" }

        base_slug = @frontmatter.slug.presence || @resource.filename.sub(/^[\d-]+-/, "").delete_suffixes(dot_prepended_allowed_extensions)

        if @resource.previewable?
          "#{base_slug}-#{@resource.preview_token}"
        else
          base_slug
        end
      end

      private

      def dot_prepended_allowed_extensions = Perron.configuration.allowed_extensions.map { ".#{it}" }
    end
  end
end
