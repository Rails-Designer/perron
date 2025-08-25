# frozen_string_literal: true

module Perron
  class Resource
    module Associations
      extend ActiveSupport::Concern

      class_methods do
        def belongs_to(association_name, options = {})
          define_method(association_name) do
            @_belongs_to_cache ||= {}
            return @_belongs_to_cache[association_name] if @_belongs_to_cache.key?(association_name)

            class_name = options[:class_name] || "Content::#{association_name.to_s.classify}"
            associated_class = class_name.constantize

            foreign_key = (options[:foreign_key] || association_name).to_s
            slug_to_find = self.metadata[foreign_key]

            @_belongs_to_cache[association_name] = slug_to_find ? associated_class.find(slug_to_find) : nil
          end
        end

        def has_many(association_name, options = {})
          define_method(association_name) do
            @_has_many_cache ||= {}
            return @_has_many_cache[association_name] if @_has_many_cache.key?(association_name)

            class_name = options[:class_name] || "Content::#{association_name.to_s.singularize.classify}"
            associated_class = class_name.constantize

            base_name = self.class.name.demodulize.underscore
            foreign_key = (options[:foreign_key] || base_name).to_s

            primary_key_method = options.fetch(:primary_key, :slug)
            lookup_value = self.public_send(primary_key_method)

            @_has_many_cache[association_name] = associated_class.all.select do |record|
              record.metadata[foreign_key] == lookup_value
            end
          end
        end
      end
    end
  end
end
