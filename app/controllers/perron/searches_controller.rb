# frozen_string_literal: true

module Perron
  class SearchesController < ApplicationController
    before_action :force_json, only: %w[show]

    def show
      resources = search_scope.flat_map(&:all)
      index = resources.map do |resource|
        base_fields(resource).merge(additional_search_fields(resource))
      end

      render json: index
    end

    private

    def force_json
      request.format = :json
    end

    def search_scope
      Perron
        .configuration
        .search_scope
        .map { "Content::#{it.classify}".safe_constantize }
        .compact_blank
    end

    def base_fields(resource)
      {
        slug: polymorphic_path(resource),
        href: polymorphic_path(resource),
        title: resource.try(:title) || resource.metadata.title,
        headings: resource.extracted_headings.flatten.join(" "),
        body: resource.sweeped_content
      }
    end

    def additional_search_fields(resource)
      return {} unless resource.class.search_fields_list.any?

      resource.class.search_fields_list.to_h do |field|
        [field, resource.public_send(field)]
      end
    end
  end
end
