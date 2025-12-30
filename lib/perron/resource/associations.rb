# frozen_string_literal: true

module Perron
  class Resource
    module Associations
      extend ActiveSupport::Concern

      class_methods do
        def belongs_to(association_name, **options)
          define_method(association_name) do
            cache_belongs_to_association(association_name) do
              associated_class = association_class_for(association_name, **options)
              foreign_key = foreign_key_for(association_name, **options)
              identifier = metadata[foreign_key]

              identifier ? associated_class.find(identifier) : nil
            end
          end
        end

        def has_many(association_name, **options)
          define_method(association_name) do
            cache_has_many_association(association_name) do
              associated_class = association_class_for(association_name, singularize: true, **options)
              ids_key = "#{association_name}_ids"

              metadata[ids_key] ?
                records_for_ids(associated_class, metadata[ids_key]) :
                records_for_foreign_key(associated_class, association_name, **options)
            end
          end
        end
      end

      private

      def cache_belongs_to_association(name)
        @belongs_to_cache ||= {}
        return @belongs_to_cache[name] if @belongs_to_cache.key?(name)

        @belongs_to_cache[name] = yield
      end

      def foreign_key_for(base_name, **options)
        (options[:foreign_key] || "#{base_name}_id").to_s
      end

      def cache_has_many_association(name)
        @has_many_cache ||= {}
        return @has_many_cache[name] if @has_many_cache.key?(name)

        @has_many_cache[name] = yield
      end

      def association_class_for(association_name, singularize: false, **options)
        if options[:class_name]
          options[:class_name].to_s.constantize
        else
          name = association_name.to_s
          name = name.singularize if singularize

          "Content::#{name.classify}".constantize
        end
      end

      def records_for_ids(associated_class, ids)
        ids = Array(ids)

        associated_class.all.select { ids.include?(it[:id]) || ids.include?(it["id"]) }
      end

      def records_for_foreign_key(associated_class, association_name, **options)
        foreign_key = foreign_key_for(inverse_association_name, **options)
        primary_key_method = options.fetch(:primary_key, :slug)
        lookup_value = public_send(primary_key_method)

        associated_class.all.select { it.association_value(foreign_key) == lookup_value }
      end

      def inverse_association_name = self.class.name.demodulize.underscore
    end
  end
end
