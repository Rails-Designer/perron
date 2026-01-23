# frozen_string_literal: true

module Perron
  class Resource
    module Core
      extend ActiveSupport::Concern

      def persisted? = true

      def to_model = self

      def model_name = self.class.model_name

      def association_value(key) = metadata[key]

      def to_partial_path
        @to_partial_path ||= begin
          element = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.demodulize(self.class.model_name))
          collection = ActiveSupport::Inflector.tableize(self.class.model_name)

          File.join("content", collection, element)
        end
      end
    end
  end
end
