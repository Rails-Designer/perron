# frozen_string_literal: true

require "perron/site/builder/route_resources"

module Perron
  module Site
    class Builder
      class Sitemap
        include RouteResources

        def initialize(output_path)
          @output_path = output_path
        end

        def generate
          return if !Perron.configuration.sitemap.enabled

          @entries = Hash.new { |entries, key| entries[key] = {} }

          sitemap_locales.each do |locale|
            if locale
              I18n.with_locale(locale) { collect_entries(locale) }
            else
              collect_entries(locale)
            end
          end

          File.write(@output_path.join("sitemap.xml"), to_xml)
        end

        private

        def sitemap_locales
          Perron::Locales.enabled? ? Perron::Locales.available_locales : [nil]
        end

        def collect_entries(locale)
          add_additional_routes(locale: locale)

          buildable_routes.each do |route|
            add_resource_url(route, locale: locale) if route.defaults[:action].in?(%w[index show])
          end
        end

        private

        def add_resource_url(route, locale:)
          if route.defaults[:action] == "show" && route.required_keys.difference(%i[controller action]).any?
            add_show_urls(route, locale: locale)
          else
            add_index_url(route, locale: locale)
          end
        end

        def add_show_urls(route, locale:)
          resources_for(route).reject(&:root?).each do |resource|
            next if resource.metadata.sitemap == false

            add_show_url(route, resource, locale: locale)
          end
        end

        def add_additional_routes(locale:)
          (Perron.configuration.additional_routes || []).each do |route_name|
            url_name = route_name.to_s.sub(/_path\z/, "_url")

            next unless routes.respond_to?(url_name)

            locale_options = locale_url_options_for(url_name)
            next if url_name.to_s == "localized_root_url" && locale_options[:locale].nil?

            location = routes.public_send(
              url_name,
              **Perron.configuration.default_url_options,
              **locale_options
            )

            @entries[url_entry_key(route_name)][locale] = {
              location: location,
              priority: Perron.configuration.sitemap.priority,
              changefreq: Perron.configuration.sitemap.change_frequency,
              lastmod: Time.current.iso8601
            }
          end
        end

        def add_index_url(route, locale:)
          collection = collection_for(route)
          return if collection&.configuration&.sitemap&.enabled == false

          entry_key = "#{route.name}:index"

          url_options = Perron.configuration.default_url_options
          url_options = url_options.merge(trailing_slash: false) if route.path.spec.to_s.match?(/\.\w+/)
          url_options = url_options.merge(locale_url_options_for(route))

          location = routes.public_send("#{route.name}_url", **url_options)

          @entries[entry_key][locale] = {
            location: location,
            priority: Perron.configuration.sitemap.priority,
            changefreq: Perron.configuration.sitemap.change_frequency,
            lastmod: last_modified_for(collection)
          }
        end

        def add_show_url(route, resource, locale:)
          collection = collection_for(route)
          return if collection&.configuration&.sitemap&.enabled == false

          entry_key = "#{route.name}:#{resource.translation_key}"

          priority = resource.metadata.sitemap_priority || collection&.configuration&.sitemap&.priority || Perron.configuration.sitemap.priority
          change_frequency = resource.metadata.sitemap_change_frequency || collection&.configuration&.sitemap&.change_frequency || Perron.configuration.sitemap.change_frequency

          url_options = Perron.configuration.default_url_options
          url_options = url_options.merge(trailing_slash: false) if route.path.spec.to_s.match?(/\.\w+/)

          location = if resource.root?
            routes.root_url(**url_options, **locale_url_options_for(route)).to_s
          else
            routes.public_send("#{route.name}_url", resource, **url_options, **locale_url_options_for(route))
          end

          @entries[entry_key][locale] = {
            location: location,
            priority: priority,
            changefreq: change_frequency,
            lastmod: resource.metadata.updated_at&.iso8601
          }
        end

        def url_entry_key(route_name)
          (route_name.to_s == "localized_root_path") ? "root_path" : route_name.to_s
        end

        def last_modified_for(collection)
          return unless collection

          collection_resources = collection.send(:load_resources).select(&:buildable?)
          modification_dates = collection_resources.filter_map { it.metadata.updated_at || it.metadata.publication_date }

          modification_dates.max&.iso8601
        end

        def to_xml
          Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
            urlset_attributes = {xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9"}
            urlset_attributes["xmlns:xhtml"] = "http://www.w3.org/1999/xhtml" if localized?

            xml.urlset(urlset_attributes) do
              each_deduplicated_url_entry do |entry, group|
                add_url_entry(xml, entry, group)
              end
            end
          end.to_xml
        end

        def each_deduplicated_url_entry
          emitted_locations = []

          @entries.each_value do |group|
            group.each do |locale, entry|
              next if emitted_locations.include?(entry[:location])

              emitted_locations << entry[:location]

              yield entry, group
            end
          end
        end

        def add_url_entry(xml, entry, group)
          xml.url do
            xml.loc entry[:location]
            xml.priority entry[:priority]
            xml.changefreq entry[:changefreq]
            xml.lastmod entry[:lastmod] if entry[:lastmod]

            next unless localized?

            group.each do |locale, alternate|
              xml["xhtml"].link(rel: "alternate", hreflang: locale.to_s, href: alternate[:location])
            end

            xml["xhtml"].link(rel: "alternate", hreflang: "x-default", href: default_location(group))
          end
        end

        def default_location(group)
          default = group[Perron::Locales.default_locale.to_sym] || group.values.first
          default[:location]
        end

        def localized?
          @entries.values.any? { it.many? }
        end

        def routes = Rails.application.routes.url_helpers
      end
    end
  end
end
