# frozen_string_literal: true

module Perron
  module PaginateHelper
    def paginate(scope, page: nil, **options)
      page ||= (params[:page] || 1).to_i
      resource_class = scope.model_class

      config = resource_class.configuration.pagination
      per_page = options[:per_page] || config.per_page
      page_path_template = options[:path_template] || config.path_template

      route = find_index_route(resource_class)
      base_path = route_path(route)

      use_query_params = Rails.env.development? || Rails.env.local?
      paginate = Paginate.new(scope, page: page, per_page: per_page, base_path: base_path, page_path_template: page_path_template, use_query_params: use_query_params)

      [paginate, paginate.items]
    end

    private

    def find_index_route(resource_class)
      controller_name = resource_class.name.demodulize.sub("Controller", "").underscore.pluralize

      Rails.application.routes.routes.find do |r|
        r.defaults[:controller] == "content/#{controller_name}" &&
          r.defaults[:action] == "index"
      end
    end

    def route_path(route)
      return "/#{route.name}/" unless route

      path_spec = route.path.spec.to_s
      path_spec.sub(/\(.*?\)/, "").gsub(/:[^\/]+/, "").sub(/\/$/, "") + "/"
    end
  end
end
