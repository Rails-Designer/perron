# frozen_string_literal: true

module Perron
  class Resource
    module Core
      extend ActiveSupport::Concern

      def persisted? = true

      def to_model = self

      def model_name = self.class.model_name
    end
  end
end
