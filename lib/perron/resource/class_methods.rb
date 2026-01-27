# frozen_string_literal: true

module Perron
  class Resource
    module ClassMethods
      extend ActiveSupport::Concern

      class_methods do
        def find(slug) = collection.find(slug, name.constantize)

        def all = collection.all(self)

        def where(**conditions) = all.where(**conditions)

        def limit(count) = all.limit(count)

        def offset(count) = all.offset(count)

        def count = all.size

        def order(attribute, direction = :asc) = all.order(attribute, direction)

        def first(n = nil)
          n ? all.first(n) : all[0]
        end

        def second = all[1]

        def third = all[2]

        def fourth = all[3]

        def fifth = all[4]

        def forty_two = all[41]

        def last = all.last

        def take(n) = all.first(n)

        def collection = Collection.new(collection_name)

        def root = all.find(&:root?)

        def model_name
          @model_name ||= ActiveModel::Name.new(self, nil, name.demodulize.to_s)
        end

        private

        def collection_name = name.demodulize.underscore.pluralize.inquiry
      end
    end
  end
end
