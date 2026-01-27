# frozen_string_literal: true

module Perron
  class Relation < Array
    def initialize(resources = [])
      super
    end

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

      Relation.new(filtered)
    end

    def limit(count) = Relation.new(first(count))

    def offset(count) = Relation.new(drop(count))

    def order(attribute, direction = :asc)
      sorted = sort_by { it.public_send(attribute) }

      Relation.new((direction == :desc) ? sorted.reverse : sorted)
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
