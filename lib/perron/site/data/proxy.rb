# frozen_string_literal: true

module Perron
  class Data
    class Proxy
      def method_missing(method_name, *arguments, &block)
        raise ArgumentError, "Data `#{method_name}` does not accept arguments" if arguments.any?

        Perron::Data.new(method_name.to_s)
      end

      def respond_to_missing?(method_name, include_private = false)
        true
      end
    end
  end
end
