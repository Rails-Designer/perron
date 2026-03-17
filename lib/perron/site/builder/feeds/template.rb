# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class Feeds
        module Template
          def find_template(type)
            collection_name = @collection.name.to_s.pluralize

            user_path = Rails.root.join("app/views/content/#{collection_name}/#{type}.erb")
            return user_path if File.exist?(user_path)

            default_path = Pathname.new(__dir__).join("#{type}.erb")
            return default_path if File.exist?(default_path)

            nil
          end

          def render(template_path, feed_config)
            template = File.read(template_path)
            b = binding

            b.local_variable_set(:collection, @collection)
            b.local_variable_set(:resources, resources)
            b.local_variable_set(:config, feed_config)
            b.local_variable_set(:routes, routes)
            b.local_variable_set(:author, method(:author))
            b.local_variable_set(:url_for_resource, method(:url_for_resource))
            b.local_variable_set(:current_feed_url, method(:current_feed_url))

            ERB.new(template).result(b)
          end

          def url_for_resource(resource)
            routes
              .polymorphic_url(resource, **@configuration.default_url_options.merge(ref: feed_configuration.ref))
              .delete_suffix("?ref=")
          rescue
            nil
          end

          def current_feed_url
            path = feed_configuration.path || "feed.atom"
            URI.join(@configuration.url, path).to_s
          end

          def routes
            Rails.application.routes.url_helpers
          end

          def feed_configuration
            case self.class.name.demodulize
            when "Rss" then @collection.configuration.feeds.rss
            when "Atom" then @collection.configuration.feeds.atom
            when "Json" then @collection.configuration.feeds.json
            end
          end
        end
      end
    end
  end
end
