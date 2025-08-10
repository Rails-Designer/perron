# frozen_string_literal: true

require "json"

module Perron
  module Site
    class Builder
      class Feeds
        class Json
          def initialize(collection:)
            @collection = collection
            @configuration = Perron.configuration
          end

          def generate
            return nil if resources.empty?

            hash = Rails.application.routes.url_helpers.with_options(@configuration.default_url_options) do |url|
              {
                version: "https://jsonfeed.org/version/1.1",
                title: @configuration.site_name,
                home_page_url: @configuration.url,
                description: @configuration.site_description,
                items: resources.map do |resource|
                  {
                    id: resource.id,
                    url: url.polymorphic_url(resource),
                    date_published: (resource.metadata.published_at || resource.metadata.updated_at)&.iso8601,
                    title: resource.metadata.title,
                    content_html: Perron::Markdown.render(resource.content)
                  }
                end
              }
            end

            JSON.pretty_generate hash
          end

          private

          def resources
            @resources ||= @collection.resources
              .reject { it.metadata.feed == false }
              .sort_by { it.metadata.published_at || it.metadata.updated_at || Time.current }
              .reverse
              .take(@collection.configuration.feeds.json.max_items)
          end
        end
      end
    end
  end
end
