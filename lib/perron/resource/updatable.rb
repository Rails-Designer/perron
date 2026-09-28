# frozen_string_literal: true

module Perron
  class Resource
    module Updatable
      extend ActiveSupport::Concern

      included do
        def metadata
          @metadata ||= Proxy.new(super, self)
        end
      end

      class Proxy
        def initialize(metadata, resource)
          @metadata = metadata
          @resource = resource
        end

        def update(attributes)
          attributes = attributes.deep_symbolize_keys

          separator = Perron::Resource::Separator.new(@resource.raw_content)
          frontmatter = separator.frontmatter.to_h.merge(attributes)
          yaml = frontmatter.transform_keys(&:to_s).to_yaml.sub(/\A---\n/, "")
          body = separator.content

          File.write(@resource.file_path, "---\n#{yaml}---\n\n#{body}\n")

          @resource.instance_variable_set(:@frontmatter, nil)
          attributes.each { |key, value| @metadata[key] = value }

          self
        end

        def respond_to_missing?(name, include_private = false)
          @metadata.respond_to?(name, include_private) || super
        end

        def method_missing(name, *arguments, &block)
          @metadata.public_send(name, *arguments, &block)
        end
      end
    end
  end
end
