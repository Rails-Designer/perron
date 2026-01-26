# frozen_string_literal: true

module Content
  module Data
    def self.new(identifier)
      Perron::DataSource.new(identifier)
    end

    def self.const_missing(name)
      klass = Class.new(Perron::DataSource) do
        def self.const_missing(nested_name) = const_set(nested_name, Class.new(Perron::DataSource))
      end

      const_set(name, klass)
    end
  end
end
