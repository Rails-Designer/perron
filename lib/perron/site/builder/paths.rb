# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class Paths
        def initialize(collection, paths)
          @collection, @paths = collection, paths
        end

        def get
          @paths << routes.public_send(index_path) if routes.respond_to?(index_path)

          if routes.respond_to?(show_path)
            @collection.all.each do |resource|
              root = resource.root?

              next if skip? root

              @paths << (root ? routes.root_path : routes.public_send(show_path, resource))
            end
          end
        end

        private

        def skip?(root)
          root &&
            Perron.configuration.mode.integrated? && Perron.configuration.exclude_root?
        end

        def routes = Rails.application.routes.url_helpers

        def index_path = "#{@collection.name}_path"

        def show_path = "#{@collection.name.singularize}_path"
      end
    end
  end
end
