# frozen_string_literal: true

require "perron/json_ld/schemas/base"

module Perron::JsonLd::Schemas
  class WebSiteSchema < Base
    private

    def properties
      {
        name: data.name,
        url: data.url
      }
    end
  end
end
