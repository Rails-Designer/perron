# frozen_string_literal: true

require "json"
require "perron/site/builder/feeds/author"

module Perron
  module Site
    class Builder
      class Feeds
        class Json
          include Feeds::Author

          def initialize(collection:)
            @collection = collection
            @configuration = Perron.configuration
          end

          def generate
            return nil if resources.empty?

            hash = Rails.application.routes.url_helpers.with_options(@configuration.default_url_options) do |url|
              {
                generator: "Perron (#{Perron::VERSION})",
                version: "https://jsonfeed.org/version/1.1",
                home_page_url: @configuration.url,
                title: feed_configuration.title.presence || @configuration.site_name,
                description: feed_configuration.description.presence || @configuration.site_description,
                items: resources.map do |resource|
                  {
                    id: resource.id,
                    url: url.polymorphic_url(resource, ref: feed_configuration.ref).delete_suffix("?ref="),
                    date_published: resource.published_at&.iso8601,
                    authors: authors(resource),
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
              .take(feed_configuration.max_items)
          end

          def feed_configuration = @collection.configuration.feeds.json

          def authors(resource)
            author = author(resource)

            return nil unless author&.name

            [{name: author.name, email: author.email, url: author.url, avatar: author.avatar}.compact].presence
          end
        end
      end
    end
  end
end
