# frozen_string_literal: true

require "nokogiri"

module Perron
  module Site
    class Builder
      class Feeds
        class Rss
          def initialize(collection:, config:)
            @collection = collection
            @config = config
            @site_config = Perron.configuration
          end

          def generate
            return if resources.empty?

            Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
              xml.rss(:version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom") do
                xml.channel do
                  xml.title @site_config.site_name
                  xml.description @site_config.site_description
                  xml.link @site_config.url

                  Rails.application.routes.url_helpers.with_options(@site_config.default_url_options) do |url|
                    resources.each do |resource|
                      xml.item do
                        xml.guid url.polymorphic_url(resource), isPermaLink: "true"
                        xml.link url.polymorphic_url(resource)
                        xml.pubDate((resource.metadata.published_at || resource.metadata.updated_at)&.rfc822)
                        xml.title resource.metadata.title
                        xml.description { xml.cdata(resource.content) }
                      end
                    end
                  end
                end
              end
            end.to_xml
          end

          private

          def resources
            @resource ||= @collection.resources
              .reject { it.metadata.feed == false }
              .sort_by { it.metadata.published_at || it.metadata.updated_at || Time.current }
              .reverse
              .take(@config.max_items)
          end
        end
      end
    end
  end
end
