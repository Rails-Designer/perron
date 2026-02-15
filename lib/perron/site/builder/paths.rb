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
            paths_for(route).each { @paths << it }
          end
        end

        private

        def buildable_routes
          Rails.application.routes.routes.select do |route|
            route.defaults[:controller]&.start_with?("content/") &&
              %w[index show].include?(route.defaults[:action])
          end
        end

        def paths_for(route)
          case route.defaults[:action]
          when "index" then [routes.public_send("#{route.name}_path")]
          when "show" then show_paths_for(route)
          else []
          end
        end

        def show_paths_for(route)
          resources_for(route).reject(&:root?).map do |resource|
            routes.public_send("#{route.name}_path", resource)
          end
        end

        private

        def parent_controller_for(route)
          parts = route.defaults[:controller].split("/")
          return nil if parts.length < 3

          "content/#{parts[-2]}"
        end

        def resources_for(route)
          collection = collection_for(route)
          return [] unless collection

          resources = collection.send(:load_resources).select(&:buildable?)
          constraint = route.path.requirements[:id]

          constraint.is_a?(Regexp) ? resources.select { constraint.match?(it.to_param) } : resources
        end

        def collection_for(route)
          controller_name = route.defaults[:controller].split("/").last
          collection_name = controller_name.chomp("_controller")
          collection = Perron::Site.find_collection(collection_name)

          return collection if collection

          parent_controller = route.defaults[:controller].split("/")[-2]
          return nil unless parent_controller

          parent_collection_name = parent_controller.chomp("_controller")
          Perron::Site.find_collection(parent_collection_name)
        end

        def routes = Rails.application.routes.url_helpers
      end
    end
  end
end
