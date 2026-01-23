# frozen_string_literal: true

module Perron
  class Resource
    module Searchable
      extend ActiveSupport::Concern

      included do
        class_attribute :search_fields_list, default: []
      end

      class_methods do
        def search_fields(*fields)
          self.search_fields_list = fields
        end
      end
    end
  end
end
