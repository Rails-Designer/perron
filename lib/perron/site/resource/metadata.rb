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
          .merge(
              apply_fallbacks_and_defaults(to: site_and_collection_data)
            )
      end

      private

      def site_and_collection_data = site_data.merge(collection_data).merge(@frontmatter)

      def apply_fallbacks_and_defaults(to:)
        to[:title] ||= @config.site_name || Rails.application.name.underscore.camelize

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
        url_options = @config.default_url_options
        base_url = "#{url_options[:protocol]}://#{url_options[:host]}"
        url = URI.join(base_url, @resource.path).to_s
        has_extension = URI(url).path.split("/").last&.include?(".")

        url.then { (url_options[:trailing_slash] && !it.end_with?("/") && !has_extension) ? "#{it}/" : it }
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
