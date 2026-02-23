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
          when "index"
            required_params = route.required_keys - [:controller, :action]
            if required_params.any?
              raise "Route `#{route.name}` (#{route.path.spec}) is an index route but requires parameters #{required_params}. Perron doesn't know how to generate these parameters."
            end

            [routes.public_send("#{route.name}_path")]
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
          constraint_resources = constraint_resources_from(route)
          return constraint_resources if constraint_resources.any?

          collection = collection_for(route)
          return [] unless collection

          resources = collection.send(:load_resources).select(&:buildable?)
          constraint = route.path.requirements[:id]

          constraint.is_a?(Regexp) ? resources.select { constraint.match?(it.to_param) } : resources
        end

        def collection_for(route)
          collection = standard_collection(route)
          return collection if collection

          collection = parent_collection(route)
          return collection if collection

          constraint_collection(route)
        end

        def routes = Rails.application.routes.url_helpers

        private

        def standard_collection(route)
          controller_class = "#{route.defaults[:controller]}_controller".classify.constantize
          collection_name = controller_class.respond_to?(:collection_name) ? controller_class.collection_name : route.defaults[:controller].split("/").last.chomp("_controller")

          Perron::Site.find_collection(collection_name)
        rescue NameError
          Perron::Site.find_collection(route.defaults[:controller].split("/").last.chomp("_controller"))
        end

        def parent_collection(route)
          parent_controller = route.defaults[:controller].split("/")[-2]
          return nil unless parent_controller

          Perron::Site.find_collection(parent_controller.chomp("_controller"))
        end

        def constraint_collection(route)
          constraint = route.path.requirements[:id]
          return nil unless constraint.is_a?(Regexp)
          return nil unless constraint.source.include?("|")

          values = constraint.source.split("|")
          return nil unless values.all? { it.match?(/\A\w+\z/) }

          ConstraintCollection.new(values)
        end

        def constraint_resources_from(route)
          constraint = route.path.requirements[:id]
          return [] unless constraint.is_a?(Regexp)
          return [] unless constraint.source.include?("|")

          values = constraint.source.split("|")
          return [] unless values.all? { it.match?(/\A\w+\z/) }

          values.map { ConstraintResource.new(it) }
        end

        class ConstraintCollection
          def initialize(values)
            @values = values
          end

          def load_resources
            @values.map { ConstraintResource.new(it) }
          end
        end

        class ConstraintResource
          def initialize(value)
            @value = value
          end

          def to_param = @value

          def buildable? = true

          def root? = false
        end
      end
    end
  end
end
