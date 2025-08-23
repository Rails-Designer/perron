# frozen_string_literal: true

module Perron
  class Data
    class Proxy
      include Enumerable

      def initialize(parts = [])
        @parts = parts
        @data = data_for_proxy
      end

      def each(&block) = @data.each(&block)

      def inspect = @data.inspect

      def respond_to_missing?(name, include_private = false)
        identifier = File.join(*@parts, name.to_s)

        Perron::Data.directory?(identifier) || Perron::Data.path_for(identifier) || super
      end

      def method_missing(name, *arguments, &block)
        raise ArgumentError, "Data access does not accept arguments" if arguments.any? || block

        new_parts = @parts + [name.to_s]
        identifier = File.join(*new_parts)

        return Proxy.new(new_parts) if Perron::Data.directory?(identifier)
        return Perron::Data.new(identifier) if Perron::Data.path_for(identifier)

        super
      end

      private

      def data_for_proxy
        return [] if @parts.empty?

        identifier = File.join(*@parts)
        data_path = Perron::Data.path_for(identifier) || Perron::Data.path_for(File.join(identifier, "index"))

        data_path ? Perron::Data.new(data_path) : []
      end
    end
  end
end
