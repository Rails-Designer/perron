# frozen_string_literal: true

module Perron
  class JsonLd
    include ActionView::Helpers::TagHelper

    def initialize(data)
      @schemas_data = Array.wrap(data)
    end

    def render
      return if @schemas_data.blank?

      script_tags = @schemas_data.filter_map do |schema_data|
        build_script_tag(with: schema_data)
      end

      safe_join(script_tags, "\n")
    end

    private

    def build_script_tag(with:)
      # builder = builder_for(type: with[:type])
      type = "#{with[:type]}_schema".camelize
      builder = "Perron::JsonLd::Schemas::#{type}".safe_constantize

      return if builder.blank?

      json_content = builder.new(from: with).build.to_json

      tag.script(json_content.html_safe, type: "application/ld+json")
    rescue KeyError => error
      Rails.logger.warn("Perron::JsonLd: #{error.message}")
    end

    # def builder_for(type:)
    #   class_name = "#{type}_schema".camelize

    #   "Perron::JsonLd::Schemas::#{class_name}".safe_constantize
    # end
  end
end
