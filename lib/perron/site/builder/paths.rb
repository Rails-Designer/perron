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
            @collection.send(:load_resources).select(&:buildable?).each do |resource|
              @paths << routes.public_send(show_path, resource)

              (resource.class.try(:nested_routes) || []).each do |nested|
                @paths << routes.polymorphic_path([resource, nested])
              end
            end
          end
        end

        private

        def routes = Rails.application.routes.url_helpers

        def index_path = "#{@collection.name}_path"

        def show_path = "#{@collection.name.singularize}_path"
      end
    end
  end
end
