# frozen_string_literal: true

module Content
  module Data
    def self.const_missing(name)
      klass = Class.new(Perron::Data) do
        def self.const_missing(nested_name) = const_set(nested_name, Class.new(Perron::Data))
      end

      const_set(name, klass)
    end
  end
end
