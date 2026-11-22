# frozen_string_literal: true

module Perron
  class Resource
    module Adjacency
      extend ActiveSupport::Concern

      class_methods do
        def adjacent_by(position_method, within: {})
          grouping_method = within.is_a?(Hash) ? within.keys.first : within.presence
          grouping_order = within.is_a?(Hash) ? within.values.first : nil

          # A missing position sorts after real ones. The collection index is
          # part of that key: sort_by does not keep equal keys in order, and
          # Relation#order already keeps those nils in collection order.
          ordered = ->(resources) do
            resources.sort_by.with_index do |resource, index|
              value = resource.public_send(position_method)
              position_key = value.nil? ? [1, index] : [0, value]

              if grouping_method
                group_value = resource.public_send(grouping_method)
                group_order = if grouping_order
                  grouping_order.index(group_value.to_s) || grouping_order.index(group_value.to_s.to_sym) || Float::INFINITY
                else
                  group_value.to_s
                end

                [group_order, *position_key]
              else
                position_key
              end
            end
          end

          define_method(:next) do
            resources = ordered.call(self.class.all)

            return if (position = resources.index { it.id == id }).nil? || position >= resources.size - 1

            resources[position + 1]
          end

          define_method(:previous) do
            resources = ordered.call(self.class.all)

            return if (position = resources.index { it.id == id }).nil? || position <= 0

            resources[position - 1]
          end
        end
      end

      included do
        define_method(:next) do
          resources = self.class.all
          return if (position = resources.index { it.id == id }).nil? || position >= resources.size - 1

          resources[position + 1]
        end

        define_method(:previous) do
          resources = self.class.all
          return if (position = resources.index { it.id == id }).nil? || position <= 0

          resources[position - 1]
        end
      end
    end
  end
end
