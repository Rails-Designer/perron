# frozen_string_literal: true

require "perron/feeds/split"

module Perron
  class Feeds
    include ActionView::Helpers::TagHelper
    include Perron::Feeds::Split

    def render(options = {})
      html_tags = []

      Rails.application.routes.url_helpers.with_options(Perron.configuration.default_url_options) do |url|
        Perron::Site.collections.each do |collection|
          collection_name = collection.name.to_s

          next if options[:only]&.map(&:to_s)&.exclude?(collection_name)
          next if options[:except]&.map(&:to_s)&.include?(collection_name)
          next if collection.configuration.blank?

          collection.configuration.feeds.each do |type, feed|
            next unless feed.enabled && feed.path && MIME_TYPES.key?(type)

            absolute_url = URI.join(url.root_url, feed.path).to_s
            title = "#{collection.name.humanize} #{type.to_s.humanize} Feed"

            html_tags << tag(:link, rel: "alternate", type: MIME_TYPES[type], title: title, href: absolute_url)

            next unless feed[:split_by]

            split_values(collection.resources, feed[:split_by][:extractor]).each do |value|
              split_path = split_path_for(feed, value)
              split_url = URI.join(url.root_url, split_path).to_s
              split_title = "#{collection.name.humanize}: #{value.to_s.humanize} #{type.to_s.humanize} Feed"

              html_tags << tag(:link, rel: "alternate", type: MIME_TYPES[type], title: split_title, href: split_url)
            end
          end
        end
      end

      safe_join(html_tags, "\n")
    end

    private

    MIME_TYPES = {
      atom: "application/atom+xml",
      json: "application/json",
      rss: "application/rss+xml"
    }
  end
end
