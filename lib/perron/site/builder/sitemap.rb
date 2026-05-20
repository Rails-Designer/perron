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

          added_urls = Set.new

          xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
            builder.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
              add_additional_routes(with: builder)

              buildable_routes.each do |route|
                case route.defaults[:action]
                when "index"
                  add_index_url(route, with: builder, added_urls: added_urls)
                when "show"
                  if (route.required_keys - %i[controller action]).empty?
                    add_index_url(route, with: builder, added_urls: added_urls)
                  else
                    resources_for(route).reject(&:root?).each do |resource|
                      next if resource.metadata.sitemap == false

                      add_show_url(route, resource, with: builder, added_urls: added_urls)
                    end
                  end
                end
              end
            end
          end.to_xml

          File.write(@output_path.join("sitemap.xml"), xml)
        end

        private

        def add_additional_routes(with:)
          (Perron.configuration.additional_routes || []).each do |route_name|
            next unless routes.respond_to?(route_name)

            routes.with_options(Perron.configuration.default_url_options) do |url|
              with.url do
                with.loc url.public_send(route_name.to_s.gsub("_path", "_url"))
                with.priority Perron.configuration.sitemap.priority
                with.changefreq Perron.configuration.sitemap.change_frequency
                with.lastmod Time.current.iso8601
              end
            end
          end
        end

        def add_index_url(route, with:, added_urls:)
          collection = collection_for(route)
          return if collection&.configuration&.sitemap&.enabled == false

          url_options = Perron.configuration.default_url_options
          url_options = url_options.merge(trailing_slash: false) if route.path.spec.to_s.match?(/\.\w+/)

          routes.with_options(url_options) do |url|
            loc = url.public_send("#{route.name}_url")
            next if added_urls.include?(loc)
            added_urls << loc

            lastmod = last_modified_for(collection)

            with.url do
              with.loc loc
              with.priority Perron.configuration.sitemap.priority
              with.changefreq Perron.configuration.sitemap.change_frequency
              with.lastmod lastmod if lastmod
            end
          end
        end

        def add_show_url(route, resource, with:, added_urls:)
          collection = collection_for(route)
          return if collection&.configuration&.sitemap&.enabled == false

          priority = resource.metadata.sitemap_priority || collection&.configuration&.sitemap&.priority || Perron.configuration.sitemap.priority
          change_frequency = resource.metadata.sitemap_change_frequency || collection&.configuration&.sitemap&.change_frequency || Perron.configuration.sitemap.change_frequency

          url_options = Perron.configuration.default_url_options
          url_options = url_options.merge(trailing_slash: false) if route.path.spec.to_s.match?(/\.\w+/)

          loc = resource.root? ? routes.root_url(url_options) : routes.public_send("#{route.name}_url", resource, **url_options)

          return if added_urls.include?(loc)
          added_urls << loc

          routes.with_options(Perron.configuration.default_url_options) do |url|
            with.url do
              with.loc loc
              with.priority priority
              with.changefreq change_frequency
              with.lastmod resource.metadata.updated_at&.iso8601 if resource.metadata.updated_at.present?
            end
          end
        end

        def last_modified_for(collection)
          return unless collection

          resources = collection.send(:load_resources).select(&:buildable?)
          dates = resources.filter_map { it.metadata.updated_at || it.metadata.publication_date }

          dates.max&.iso8601
        end

        def routes = Rails.application.routes.url_helpers
      end
    end
  end
end
