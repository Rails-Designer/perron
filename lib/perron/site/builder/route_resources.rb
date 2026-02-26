# frozen_string_literal: true

module Perron
  module Site
    class Builder
      module RouteResources
        def buildable_routes
          Rails.application.routes.routes.select do |route|
            route.defaults[:controller]&.start_with?("content/") &&
              %w[index show].include?(route.defaults[:action])
          end
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

          Paths::ConstraintCollection.new(values)
        end

        def constraint_resources_from(route)
          constraint = route.path.requirements[:id]
          return [] unless constraint.is_a?(Regexp)
          return [] unless constraint.source.include?("|")

          values = constraint.source.split("|")
          return [] unless values.all? { it.match?(/\A\w+\z/) }

          values.map { Paths::ConstraintResource.new(it) }
        end
      end
    end
  end
end
