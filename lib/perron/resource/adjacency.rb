# frozen_string_literal: true

module Perron
  class Resource
    module Adjacency
      extend ActiveSupport::Concern

      class_methods do
        def adjacent_by(position_method, within: {})
          grouping_method = within.is_a?(Hash) ? within.keys.first : within.presence
          grouping_order = within.is_a?(Hash) ? within.values.first : nil

          sort_by_position = ->(resources) do
            resources.sort_by.with_index do |resource, index|
              position = resource.public_send(position_method)
              position_key = position.nil? ? [1, index] : [0, position]

              if grouping_method
                group_value = resource.public_send(grouping_method)
                group_rank = grouping_order ? (grouping_order.index(group_value.to_s) || grouping_order.index(group_value.to_s.to_sym) || Float::INFINITY) : group_value.to_s

                [group_rank, *position_key]
              else
                position_key
              end
            end
          end

          define_method(:next) do
            resources = sort_by_position.call(self.class.all)

            return if (position = resources.index { it.id == id }).nil? || position >= resources.size - 1

            resources[position + 1]
          end

          define_method(:previous) do
            resources = sort_by_position.call(self.class.all)

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
