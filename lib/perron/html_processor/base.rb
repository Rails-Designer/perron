# frozen_string_literal: true

module Perron
  class HtmlProcessor
    class Base
      def initialize(html, resource: nil)
        @html, @resource = html, resource
      end

      def process
        raise NotImplementedError
      end
    end
  end
end
