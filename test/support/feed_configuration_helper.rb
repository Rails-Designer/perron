module FeedConfigurationHelper
  extend ActiveSupport::Concern

  included do
    setup do
      if defined?(@collection) && @collection
        @default_feed_attributes = {
          rss_title: @collection.configuration.feeds.rss.title,
          rss_description: @collection.configuration.feeds.rss.description,
          rss_max_items: @collection.configuration.feeds.rss.max_items,

          json_title: @collection.configuration.feeds.json.title,
          json_description: @collection.configuration.feeds.json.description,
          json_max_items: @collection.configuration.feeds.json.max_items,
        }
      end
    end

    teardown do
      if @default_feed_attributes && defined?(@collection) && @collection
        @collection.configuration.feeds.rss.title = @default_feed_attributes[:rss_title]
        @collection.configuration.feeds.rss.description = @default_feed_attributes[:rss_description]
        @collection.configuration.feeds.rss.max_items = @default_feed_attributes[:rss_max_items]

        @collection.configuration.feeds.json.title = @default_feed_attributes[:json_title]
        @collection.configuration.feeds.json.description = @default_feed_attributes[:json_description]
        @collection.configuration.feeds.json.max_items = @default_feed_attributes[:json_max_items]
      end
    end
  end
end
