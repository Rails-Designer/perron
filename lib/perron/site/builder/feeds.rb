# frozen_string_literal: true

require "perron/site/builder/feeds/atom"
require "perron/site/builder/feeds/json"
require "perron/site/builder/feeds/rss"

require "perron/feeds/split"

module Perron
  module Site
    class Builder
      class Feeds
        include Perron::Feeds::Split

        def initialize(output_path)
          @output_path = output_path
        end

        def generate
          Perron::Site.collections.each do |collection|
            next if collection.configuration.blank?

            config = collection.configuration.feeds

            generate_feed(collection: collection, type_config: config.atom, generator_class: Atom) if config.atom.enabled
            generate_feed(collection: collection, type_config: config.json, generator_class: Json) if config.json.enabled
            generate_feed(collection: collection, type_config: config.rss, generator_class: Rss) if config.rss.enabled
          end
        end

        private

        def generate_feed(collection:, type_config:, generator_class:)
          generator = generator_class.new(collection: collection)
          content = generator.generate

          create_file(at: type_config.path, with: content) if content.present?

          return unless type_config[:split_by]

          grouped_resources(collection.resources, type_config[:split_by][:extractor]).each do |value, group|
            path = split_path_for(type_config, value)
            config = split_config(type_config, value, path)
            content = generator_class.new(collection: collection, resources: group, feed_config: config).generate

            create_file(at: path, with: content) if content.present?
          end
        end

        def split_config(type_config, value, split_path)
          ActiveSupport::OrderedOptions.new.tap do |config|
            type_config.each { |key, value| config[key] = value unless key == :split_by }

            config.path = split_path
            config.title = "#{type_config.title.presence || Perron.configuration.site_name}: #{value.to_s.humanize}"
          end
        end

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
