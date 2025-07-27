# frozen_string_literal: true

module Perron
  class Resource
    module Configuration
      extend ActiveSupport::Concern

      class_methods do
        def configuration
          @configuration ||= Options.new.tap do |config|
            config.feeds = Options.new

            config.feeds.rss = ActiveSupport::OrderedOptions.new
            config.feeds.atom = ActiveSupport::OrderedOptions.new
            config.feeds.json = ActiveSupport::OrderedOptions.new

            config.linked_data = ActiveSupport::OrderedOptions.new

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
        def method_missing(name, *arguments)
          if name.to_s.end_with?("=")
            key = name.to_s.chomp("=").to_sym
            value = arguments.first

            return self[key].merge!(value) if self[key].is_a?(ActiveSupport::OrderedOptions) && value.is_a?(Hash)
          end

          super
        end

        def respond_to_missing?(name, include_private = false) = super
      end
      private_constant :Options
    end
  end
end
