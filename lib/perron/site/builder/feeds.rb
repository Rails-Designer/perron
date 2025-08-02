# frozen_string_literal: true

require "perron/site/builder/feeds/rss"
require "perron/site/builder/feeds/json"

module Perron
  module Site
    class Builder
      class Feeds
        def initialize(output_path)
          @output_path = output_path
        end

        def generate
          Perron::Site.collections.each do |collection|
            config = collection.configuration.feeds
            collection_slug = collection.name.demodulize.underscore.parameterize

            if config.rss.enabled
              path = config.rss.path || "feeds/#{collection_slug}.xml"

              if (content = builder[:rss].new(collection: collection, config: config.rss).generate)
                create_file(at: path, with: content)
              end
            end

            if config.json.enabled
              path = config.json.path || "feeds/#{collection_slug}.json"

              if (content = builder[:json].new(collection: collection, config: config.json).generate)
                create_file(at: path, with: content)
              end
            end
          end
        end

        private

        def builder
          {
            rss: Rss,
            json: Json
          }
        end

        def create_file(at:, with:)
          path = @output_path.join(at)

          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, with)
        end
      end
    end
  end
end
