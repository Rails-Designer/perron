# frozen_string_literal: true

require "perron/site/builder/route_resources"

module Perron
  module Site
    class Builder
      class Paths
        include RouteResources

        def initialize(paths)
          @paths = paths
        end

        def get
          buildable_routes.each do |route|
            paths_for(route).each { @paths << it }
          end
        end

        private

        def paths_for(route)
          case route.defaults[:action]
          when "index"
            required_params = route.required_keys - [:controller, :action]
            if required_params.any?
              raise "Route `#{route.name}` (#{route.path.spec}) is an index route but requires parameters #{required_params}. Perron doesn't know how to generate these parameters."
            end

            base_path = routes.public_send("#{route.name}_path")
            collection = collection_for(route)
            return [base_path] unless collection

            pagination = collection.configuration.pagination
            return [base_path] unless pagination.per_page

            total = collection.all.count
            total_pages = (total.to_f / pagination.per_page).ceil
            return [base_path] if total_pages <= 1

            [base_path] + (2..total_pages).map do |page_number|
              build_paginated_path(route, page_number, pagination.path_template)
            end
          when "show" then show_paths_for(route)
          else []
          end
        end

        def build_paginated_path(route, page_number, path_template)
          routes.public_send("#{route.name}_path")
            .sub(/\/$/, "") + path_template.sub(":page", page_number.to_s)
        end

        def show_paths_for(route)
          resources_for(route).reject(&:root?).map do |resource|
            routes.public_send("#{route.name}_path", resource)
          end
        end

        def routes = Rails.application.routes.url_helpers

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

          def metadata = Metadata.new

          class Metadata
            def sitemap = nil

            def sitemap_priority = nil

            def sitemap_change_frequency = nil

            def updated_at = nil
          end
        end
      end
    end
  end
end
