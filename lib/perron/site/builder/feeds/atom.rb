# frozen_string_literal: true

require "perron/site/builder/feeds/author"
require "perron/site/builder/feeds/template"

module Perron
  module Site
    class Builder
      class Feeds
        class Atom
          include Feeds::Author
          include Feeds::Template

          def initialize(collection:, resources: nil, feed_config: nil)
            @collection = collection
            @resources = resources
            @feed_config = feed_config
            @configuration = Perron.configuration
          end

          def generate
            return if resources.empty?

            template = find_template("atom")
            return unless template

            render(template, feed_configuration)
          end

          private

          def resources
            (@resources || @collection.resources)
              .reject { it.metadata.feed == false }
              .sort_by { it.metadata.published_at || it.metadata.updated_at || Time.current }
              .reverse
              .take(feed_configuration.max_items)
          end

          def feed_configuration
            @feed_config || super
          end
        end
      end
    end
  end
end
