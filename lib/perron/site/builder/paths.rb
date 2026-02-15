# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class Paths
        def initialize(paths)
          @paths = paths
        end

        def get
          buildable_routes.each do |route|
            puts "Processing route: #{route.name} -> #{route.defaults[:controller]}##{route.defaults[:action]}"

            if route.defaults[:action] == "index"
              @paths << route_path(route)
            elsif route.defaults[:action] == "show"
              collection_for(route)&.send(:load_resources)&.select(&:buildable?)&.each do |resource|
                next if resource.root?

                path = route_path(route, resource)
                @paths << path if path
              end
            end
          end
        end

        private

        def buildable_routes
          Rails.application.routes.routes.select do |route|
            route.defaults[:controller]&.start_with?("content/") &&
            %w[index show].include?(route.defaults[:action])
          end
        end

        def route_path(route, resource = nil)
          helper_name = "#{route.name}_path"

          if resource
            routes.public_send(helper_name, resource)
          else
            routes.public_send(helper_name)
          end
        rescue ActionController::UrlGenerationError
          nil
        end

        def collection_for(route)
          # TODO: is `last` smart here?;e
          controller_name = route.defaults[:controller].split("/").last
          # TODO: delete_suffix("_controller") ?
          collection_name = controller_name.chomp("_controller")

          Perron::Site.collection(collection_name)
        end

        def routes = Rails.application.routes.url_helpers
      end
    end
  end
end
