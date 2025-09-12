# frozen_string_literal: true

require "nokogiri"

module Perron
  module Site
    class Builder
      class Feeds
        class Rss
          def initialize(collection:)
            @collection = collection
            @configuration = Perron.configuration
          end

          def generate
            return if resources.empty?

            Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
              xml.rss(:version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom") do
                xml.channel do
                  xml.title feed_configuration.title.presence || @configuration.site_name
                  xml.description feed_configuration.description.presence || @configuration.site_description
                  xml.link @configuration.url
                  xml.generator "Perron (#{Perron::VERSION})"

                  Rails.application.routes.url_helpers.with_options(@configuration.default_url_options) do |url|
                    resources.each do |resource|
                      xml.item do
                        xml.guid resource.id
                        xml.link url.polymorphic_url(resource), isPermaLink: true
                        xml.pubDate((resource.metadata.published_at || resource.metadata.updated_at)&.rfc822)
                        xml.title resource.metadata.title
                        xml.description { xml.cdata(Perron::Markdown.render(resource.content)) }
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
              .take(feed_configuration.max_items)
          end

          def feed_configuration = @collection.configuration.feeds.rss
        end
      end
    end
  end
end
