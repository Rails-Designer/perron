# frozen_string_literal: true

module Perron
  class Relation < Array
    def initialize(resources = [], model_class = nil)
      super(resources)

      @model_class = model_class
    end
    attr_reader :model_class

    def where(**conditions)
      filtered = select do |resource|
        conditions.all? do |key, value|
          key_value = resource.public_send(key)

          if value.is_a?(Array)
            value.map(&:to_s).include?(key_value.to_s)
          else
            key_value.to_s == value.to_s
          end
        end
      end

      Relation.new(filtered, @model_class)
    end

    def limit(count) = Relation.new(first(count), @model_class)

    def offset(count) = Relation.new(drop(count), @model_class)

    def order(attribute, direction = :asc)
      if attribute.is_a?(Hash)
        attribute, direction = attribute.first
      end

      sorted = sort_by { it.public_send(attribute) }

      Relation.new((direction == :desc) ? sorted.reverse : sorted, @model_class)
    end

    def pluck(*attributes)
      raise ArgumentError, "wrong number of arguments (given 0, expected 1+)" if attributes.empty?

      map do |resource|
        if attributes.size == 1
          resource.public_send(attributes.first)
        else
          attributes.map { resource.public_send(it) }
        end
      end
    end
  end
end
