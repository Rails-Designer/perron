# frozen_string_literal: true

module Perron
  class Resource
    module Adjacency
      extend ActiveSupport::Concern

      class_methods do
        def adjacent_by(position_method, within: {})
          return unless within.present?

          grouping_method = within.is_a?(Hash) ? within.keys.first : within
          grouping_order = within.is_a?(Hash) ? within.values.first : nil

          define_method(:next) do
            resources = self.class.all.sort_by do |resource|
              group_value = resource.public_send(grouping_method)

              group_order = if grouping_order
                grouping_order.index(group_value.to_s) || grouping_order.index(group_value.to_sym) || Float::INFINITY
              else
                group_value.to_s
              end

              [group_order, resource.public_send(position_method)]
            end

            return if (position = resources.index { it.id == id }).nil? || position >= resources.size - 1

            resources[position + 1]
          end

          define_method(:previous) do
            resources = self.class.all.sort_by do |resource|
              group_value = resource.public_send(grouping_method)

              group_order = if grouping_order
                grouping_order.index(group_value.to_s) || grouping_order.index(group_value.to_sym) || Float::INFINITY
              else
                group_value.to_s
              end

              [group_order, resource.public_send(position_method)]
            end

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
