# frozen_string_literal: true

module Perron
  module JsonLd
    module Schemas
      class Base
        def initialize(from:)
          @data = JSON.parse(from.to_json, object_class: OpenStruct)
        end

        def build
          {
            "@context": "https://schema.org",
            "@type": type
          }.merge(properties).compact
        end

        private

        attr_reader :data

        def properties = {}

        def type = self.class.name.demodulize.chomp("Schema")
      end
    end
  end
end
