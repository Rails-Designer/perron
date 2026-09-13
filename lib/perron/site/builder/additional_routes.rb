# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class AdditionalRoutes
        include RouteResources

        def initialize(paths, only: nil)
          @paths = paths
          @only = only
        end

        def get
          Perron.configuration.additional_routes.each do |route_name|
            next unless routes.respond_to?(route_name)
            next if @only == :localized && !localizes?(route_name)
            next if @only == :rest && localizes?(route_name)

            options = locale_url_options_for(route_name)
            next if route_name.to_s == "localized_root_path" && options[:locale].nil?

            @paths << routes.public_send(route_name, **options)
          end
        end

        private

        def routes = Rails.application.routes.url_helpers
      end
    end
  end
end
