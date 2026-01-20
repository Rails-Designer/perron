# frozen_string_literal: true

module Perron
  class Resource
    module Configuration
      extend ActiveSupport::Concern

      class_methods do
        def configuration
          @configuration ||= Options.new.tap do |config|
            config.metadata = Options.new

            config.feeds = Options.new

            config.feeds.rss = ActiveSupport::OrderedOptions.new
            config.feeds.rss.enabled = false
            config.feeds.rss.path = "feeds/#{collection.name.demodulize.parameterize}.xml"
            config.feeds.rss.max_items = 20

            config.feeds.json = ActiveSupport::OrderedOptions.new
            config.feeds.json.enabled = false
            config.feeds.json.path = "feeds/#{collection.name.demodulize.parameterize}.json"
            config.feeds.json.max_items = 20

            config.related_posts = ActiveSupport::OrderedOptions.new
            config.related_posts.enabled = false
            config.related_posts.max = 5

            config.sitemap = ActiveSupport::OrderedOptions.new
            config.sitemap.exclude = false
          end
        end

        def configure
          yield(configuration)
        end
      end

      class Options < ActiveSupport::OrderedOptions
        def []=(key, value)
          if self[key].is_a?(ActiveSupport::OrderedOptions) && value.is_a?(Hash)
            self[key].merge!(value)
          else
            super
          end
        end

        def respond_to_missing?(name, include_private = false)
          name.to_s.end_with?("=") || super
        end
      end
      private_constant :Options
    end
  end
end
