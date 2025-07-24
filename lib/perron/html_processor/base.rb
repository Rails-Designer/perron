# frozen_string_literal: true

module Perron
  class HtmlProcessor
    class Base
      def initialize(html)
        @html = html
      end

      def process
        raise NotImplementedError
      end
    end
  end
end
