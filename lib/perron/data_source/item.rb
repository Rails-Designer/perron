# frozen_string_literal: true

module Perron
  class DataSource < SimpleDelegator
    class Item
      def initialize(attributes, identifier:)
        @attributes = attributes.transform_keys(&:to_sym)
        @identifier = identifier
      end

      def [](key) = @attributes[key.to_sym]

      def association_value(key) = self[key]

      def to_partial_path
        @to_partial_path ||= begin
          identifier = @identifier.to_s
          collection = File.extname(identifier).present? ? File.basename(identifier, ".*") : identifier
          element = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.singularize(File.basename(collection)))

          File.join("content", collection, element)
        end
      end

      def method_missing(method_name, *arguments, &block)
        return super if !@attributes.key?(method_name) || arguments.any? || block

        @attributes[method_name]
      end

      def respond_to_missing?(method_name, include_private = false)
        @attributes.key?(method_name) || super
      end
    end
    private_constant :Item
  end
end
