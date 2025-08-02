# frozen_string_literal: true

require "json"

module Perron
  module Site
    class Builder
      class Feeds
        class Json
          def initialize(collection:, config:)
            @collection = collection
            @config = config
            @site_config = Perron.configuration
          end

          def generate
            return nil if resources.empty?

            hash = Rails.application.routes.url_helpers.with_options(@site_config.default_url_options) do |url|
              {
                version: "https://jsonfeed.org/version/1.1",
                title: @site_config.site_name,
                home_page_url: @site_config.url,
                description: @site_config.site_description,
                items: resources.map do |resource|
                  {
                    id: resource.id,
                    url: url.polymorphic_url(resource),
                    date_published: (resource.metadata.published_at || resource.metadata.updated_at)&.iso8601,
                    title: resource.metadata.title,
                    content_html: resource.content
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
              .take(@config.max_items)
          end
        end
      end
    end
  end
end
