# frozen_string_literal: true

module Perron
  class Resource
    module Renderer
      module_function

      def erb(content, assigns = {})
        ::ApplicationController
          .renderer
          .render(
            inline: content,
            assigns: assigns
          )
      end
    end
  end
end
