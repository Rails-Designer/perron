# frozen_string_literal: true

module Perron
  class Resource
    class Metadata
      def initialize(resource:, frontmatter:, collection:)
        @resource = resource
        @frontmatter = frontmatter&.deep_symbolize_keys || {}
        @collection = collection
        @config = Perron.configuration
      end

      def data
        @data ||= ActiveSupport::OrderedOptions
          .new
          .merge(apply_fallbacks_and_defaults(to: merged_site_collection_resource_frontmatter))
      end

      private

      def merged_site_collection_resource_frontmatter = site_data.merge(collection_data).merge(@frontmatter)

      def apply_fallbacks_and_defaults(to:)
        to[:title] ||= @config.site_name || Rails.application.name.underscore.camelize

        to[:canonical_url] ||= canonical_url

        to[:og_image] ||= to[:image]
        to[:twitter_image] ||= to[:og_image]

        to[:og_title] ||= to[:title]
        to[:twitter_title] ||= to[:title]
        to[:og_description] ||= to[:description]
        to[:twitter_description] ||= to[:description]
        to[:og_type] ||= to[:type]
        to[:og_logo] ||= to[:logo]
        to[:og_author] ||= to[:author]
        to[:og_locale] ||= to[:locale]

        to[:og_site_name] = @config.site_name
        to[:twitter_card] ||= "summary_large_image"
        to[:og_url] = canonical_url
        to[:article_published_time] = @resource.published_at

        to.compact
      end

      def canonical_url
        @frontmatter[:canonical_url] ||
          Rails.application.routes.url_helpers.polymorphic_url(
            @resource,
            **Perron.configuration.default_url_options
          )
      end

      def site_data
        @config.metadata.except(:title_separator, :title_suffix).deep_symbolize_keys || {}
      end

      def collection_data
        @collection&.configuration&.metadata&.deep_symbolize_keys || {}
      end
    end
  end
end
