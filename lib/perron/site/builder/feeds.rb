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

            if config.rss.enabled
              if (xml = Rss.new(collection: collection).generate)
                create_file at: config.rss.path, with: xml
              end
            end

            if config.json.enabled
              if (json = Json.new(collection: collection).generate)
                create_file at: config.json.path, with: json
              end
            end
          end
        end

        private

        def create_file(at:, with:)
          path = @output_path.join(at)

          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, with)
        end
      end
    end
  end
end
