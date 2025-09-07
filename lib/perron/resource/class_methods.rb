# frozen_string_literal: true

module Perron
  class Resource
    module ClassMethods
      extend ActiveSupport::Concern

      class_methods do
        def find(slug) = collection.find(slug, name.constantize)

        def all = collection.all(self)

        def count = all.size

        def first = all[0]

        def second = all[1]

        def third = all[2]

        def fourth = all[3]

        def fifth = all[4]

        def forty_two = all[41]

        def last = all.last

        def take(n) = all.first(n)

        def collection = Collection.new(collection_name)

        def root
          collection_name.pages? && collection.find_by_file_name("root", name.constantize)
        end

        def model_name
          @model_name ||= ActiveModel::Name.new(self, nil, name.demodulize.to_s)
        end

        private

        def collection_name = name.demodulize.underscore.pluralize
      end
    end
  end
end
