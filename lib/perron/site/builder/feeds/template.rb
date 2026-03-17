# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class Feeds
        module Template
          def find_template(type)
            collection_name = @collection.name.to_s.pluralize
            path = Rails.root.join("app/views/content/#{collection_name}/#{type}.erb")

            path if File.exist?(path)
          end

          def render(template_path, feed_config)
            template = File.read(template_path)
            b = binding

            b.local_variable_set(:collection, @collection)
            b.local_variable_set(:resources, resources)
            b.local_variable_set(:config, feed_config)

            ERB.new(template).result(b)
          end
        end
      end
    end
  end
end
