# frozen_string_literal: true

module Perron
  class Feeds
    include ActionView::Helpers::TagHelper

    def initialize(collections)
      @collections = collections
    end

    def render(options = {})
      html_tags = []

      Rails.application.routes.url_helpers.with_options(Perron.configuration.default_url_options) do |url|
        @collections.each do |collection|
          collection_name = collection.name.to_s

          next if options[:only] && !options[:only].map(&:to_s).include?(collection_name)
          next if options[:except]&.map(&:to_s)&.include?(collection_name)

          collection.configuration[:feeds].each do |type, feed|
            next unless feed[:enabled] && feed[:path] && MIME_TYPES.key?(type)

            absolute_url = URI.join(url.root_url, feed[:path]).to_s
            title = "#{collection.name.humanize} #{type.to_s.upcase} Feed"

            html_tags << tag(:link, rel: "alternate", type: MIME_TYPES[type], title: title, href: absolute_url)
          end
        end
      end

      safe_join(html_tags, "\n")
    end

    private

    MIME_TYPES = {
      rss: "application/rss+xml",
      json: "application/json"
    }
  end
end
