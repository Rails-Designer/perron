# frozen_string_literal: true

module Perron
  class Resource
    module Scopes
      extend ActiveSupport::Concern

      class_methods do
        def scope(name, body)
          unless body.respond_to?(:call)
            raise ArgumentError, "The scope body needs to be callable."
          end

          if respond_to?(name, true)
            raise ArgumentError, "Cannot define scope :#{name} because it already exists."
          end

          singleton_class.define_method(name) do |*arguments|
            instance_exec(*arguments, &body)
          end

          Perron::Relation.define_method(name) do |*arguments|
            instance_exec(*arguments, &body)
          end
        end
      end
    end
  end
end
