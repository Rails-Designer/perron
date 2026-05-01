# frozen_string_literal: true

module Perron
  module PaginateHelper
    def paginate(resource_class, scope, page: nil)
      page ||= (params[:page] || 1).to_i
      per_page = resource_class.configuration.pagination.per_page

      route = find_index_route(resource_class)
      base_path = route_path(route)
      page_path_template = resource_class.configuration.pagination.path_template

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
