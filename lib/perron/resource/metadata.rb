# frozen_string_literal: true

module Perron
  class Resource
    class Metadata
      def initialize(resource:, frontmatter:, collection:, controller_metadata: {})
        @resource = resource
        @frontmatter = frontmatter&.deep_symbolize_keys || {}
        @collection = collection
        @controller_metadata = controller_metadata
        @config = Perron.configuration
      end

      def data
        @data ||= ActiveSupport::OrderedOptions
          .new
          .merge(apply_fallbacks_and_defaults(to: merged_metadata))
      end

      private

      def merged_metadata
        site_data
          .merge(collection_data)
          .merge(@controller_metadata)
          .merge(@frontmatter)
      end

      def apply_fallbacks_and_defaults(to:)
        to[:title] ||= @config.site_name || Rails.application.name.underscore.camelize

        to[:canonical_url] ||= canonical_url

        to[:alternate_urls] = alternate_urls if localized?

        to[:image] = absolute_url(to[:image]) if to[:image]

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
        return @frontmatter[:canonical_url] if @frontmatter[:canonical_url]

        options = Perron.configuration.default_url_options.merge(url_options)

        return Rails.application.routes.url_helpers.root_url(**options) if @resource.root?

        begin
          Rails.application.routes.url_helpers.polymorphic_url(
            @resource,
            **options
          )
        rescue
          false
        end
      end

      def url_options
        if fallback_locale?
          Perron::Locales.url_options_for(Perron::Locales.default_locale)
        else
          Perron::Locales.url_options
        end
      end

      def fallback_locale?
        return false unless localized?
        return false if I18n.locale == Perron::Locales.default_locale

        @resource.locale != I18n.locale
      end

      def alternate_urls
        return {} unless localized?

        urls = Perron::Locales.available_locales.filter_map do |pair|
          translation = translation_for(pair)
          next unless translation

          [pair.to_s, location_for(translation, pair)]
        end.to_h

        urls["x-default"] = urls[Perron::Locales.default_locale.to_s] if urls[Perron::Locales.default_locale.to_s]

        urls
      end

      def translation_for(locale)
        path = counterpart_path_for(locale) || fallback_path_for(locale)

        @resource.class.new(path) if path
      end

      def location_for(translation, locale)
        options = @config.default_url_options.merge(Perron::Locales.url_options_for(locale))

        if translation.root? && Perron::Locales.url_options_for(locale)[:locale]
          Rails.application.routes.url_helpers.localized_root_url(**options)
        elsif translation.root?
          Rails.application.routes.url_helpers.root_url(**options)
        else
          Rails.application.routes.url_helpers.polymorphic_url(translation, **options)
        end
      end

      def fallback_path_for(locale)
        return unless localized?
        return if @resource.locale
        return if locale == @resource.locale

        return @resource.file_path.to_s if Dir.exist?(File.join(collection_directory, locale.to_s))

        nil
      end

      def counterpart_path_for(locale)
        locale_directory = File.join(collection_directory, locale.to_s)

        return if locale != Perron::Locales.default_locale && !Dir.exist?(locale_directory)

        Dir.glob("#{collection_directory}/**/*.{#{Perron.configuration.allowed_extensions.join(",")}}").lazy.find do |path|
          relative_locale = path.delete_prefix("#{collection_directory}/").split("/").first

          next if File.basename(path, ".*").downcase == "readme"
          next unless locale == Perron::Locales.default_locale || relative_locale == locale.to_s
          next if locale == Perron::Locales.default_locale && Perron::Locales.available_locales.map(&:to_s).include?(relative_locale)

          File.basename(path, ".*").sub(Perron::Resource::Publishable::DATE_REGEX, "") == @resource.translation_key
        end
      end

      def collection_directory = File.join(Perron.configuration.input, @collection.name.to_s)

      def localized?
        Perron::Locales.enabled? && @collection&.localized?
      end

      def absolute_url(path)
        return path if path.blank?
        return path if path.start_with?("http://", "https://", "//")

        Perron.configuration.url.delete_suffix("/") + path
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
