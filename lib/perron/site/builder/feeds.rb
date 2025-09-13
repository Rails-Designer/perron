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
            return if collection.configuration.blank?

            config = collection.configuration.feeds

            if config.rss.enabled
              create_file at: config.rss.path, with: Rss.new(collection: collection).generate
            end

            if config.json.enabled
              create_file at: config.json.path, with: Json.new(collection: collection).generate
            end
          end
        end

        private

        def create_file(at:, with:)
          return if with.blank?

          path = @output_path.join(at)

          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, with)
        end
      end
    end
  end
end
