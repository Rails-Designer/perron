# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class Sitemap
        def initialize(output_path)
          @output_path = output_path
        end

        def generate
          return if !Perron.configuration.sitemap.enabled

          xml = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |builder|
            builder.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
              add_additional_routes(with: builder)

              Perron::Site.collections.each do |collection|
                add_urls_for(collection, with: builder)
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

        def add_urls_for(collection, with:)
          return if collection.configuration.blank?
          return if collection.configuration.sitemap.exclude == true

          collection.resources.each do |resource|
            next if resource.metadata.sitemap == false

            priority = resource.metadata.sitemap_priority || collection.configuration.sitemap.priority || Perron.configuration.sitemap.priority
            change_frequency = resource.metadata.sitemap_change_frequency || collection.configuration.sitemap.change_frequency || Perron.configuration.sitemap.change_frequency

            Rails.application.routes.url_helpers.with_options(Perron.configuration.default_url_options) do |url|
              with.url do
                with.loc resource.root? ? url.root_url : url.polymorphic_url(resource)
                with.priority priority
                with.changefreq change_frequency
                begin
                  with.lastmod resource.metadata.updated_at.iso8601
                rescue
                  Time.current.iso8601
                end
              end
            end
          end
        end

        def routes = Rails.application.routes.url_helpers
      end
    end
  end
end
