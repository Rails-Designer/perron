# frozen_string_literal: true

module Perron
  class Feeds
    module Split
      module_function

      def grouped_resources(resources, extractor)
        resources
          .flat_map { |resource| extract(resource, extractor).map { [it, resource] } }
          .group_by(&:first)
          .transform_values { it.map(&:last) }
      end

      def split_values(resources, extractor)
        resources
          .flat_map { extract(it, extractor) }
          .uniq
      end

      def extract(resource, extractor)
        value = case extractor
        when Symbol then resource.public_send(extractor)
        when Proc then extractor.call(resource)
        end

        Array(value)
      end

      def split_path_for(type_config, value)
        split_by = type_config[:split_by]

        if split_by[:path]
          split_by[:path].gsub(":value", value.to_s.parameterize)
        else
          extension = File.extname(type_config.path)
          base_path = type_config.path.delete_suffix(extension)
          field = split_by[:extractor]
          field_name = field.is_a?(Symbol) ? field.to_s : "custom"

          "#{base_path}/#{field_name}/#{value.to_s.parameterize}#{extension}"
        end
      end
    end
  end
end
