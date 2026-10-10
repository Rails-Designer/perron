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

      # Keep `nil` values out of the comparison (it raises `ArgumentError:
      # comparison of NilClass with ... failed`) and place them last, in their
      # original relative order, regardless of direction.
      present, missing = partition { |resource| !resource.public_send(attribute).nil? }
      present = present.sort_by { it.public_send(attribute) }
      present = present.reverse if direction == :desc

      Relation.new(present + missing, @model_class)
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

    def in_order_of(attribute, values, filter: true)
      return Relation.new([]) if values.empty?

      indexed = values.each_with_index.to_h

      resources = if filter
        select { indexed.key?(it.public_send(attribute)) }
          .sort_by { indexed[it.public_send(attribute)] }
      else
        sort_by { indexed[it.public_send(attribute)] || Float::INFINITY }
      end

      Relation.new(resources)
    end
  end
end
