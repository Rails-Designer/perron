# frozen_string_literal: true

require "perron/json_ld/schemas/base"

module Perron::JsonLd::Schemas
  class BreadcrumbListSchema < Base
    private

    def properties = { itemListElement: items_list }

    def items_list
      data.items&.map&.with_index(1) do |item, index|
        {
          "@type": "ListItem",
          position: index,
          name: item.name,
          item: item.url
        }
      end
    end
  end
end
