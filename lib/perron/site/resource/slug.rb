# frozen_string_literal: true

require "perron/refinements/delete_suffixes"

module Perron
  class Resource
    class Slug
      using Perron::SuffixStripping

      def initialize(resource)
        @resource = resource
        @metadata = resource.metadata
      end

      def create
        @metadata.slug.presence || @resource.filename.sub(/^[\d-]+-/, "").delete_suffixes(Perron.configuration.allowed_extensions)
      end
    end
  end
end
