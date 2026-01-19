# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class AdditionalRoutes
        def initialize(paths)
          @paths = paths
        end

        def get
          Perron.configuration.additional_routes.each do |route_name|
            @paths << routes.public_send(route_name) if routes.respond_to?(route_name)
          end
        end

        private

        def routes = Rails.application.routes.url_helpers
      end
    end
  end
end
