# frozen_string_literal: true

module Perron
  class Resource
    module Renderer
      module_function

      # Suppress annotate_rendered_view_with_filenames for inline ERB.
      # When enabled (typical only in development), Rails wraps output with
      # <!-- BEGIN/END inline template --> HTML comments. This can interfere
      # when we "markdownify" the output, resulting in the beginning of the
      # document being unstyled.
      def erb(content, assigns = {})
        suppress_rendered_view_annotations do
          ::ApplicationController
            .renderer
            .render(
              inline: content,
              assigns: assigns
            )
        end
      end

      private

      def suppress_rendered_view_annotations(&block)
        old = ActionView::Base.annotate_rendered_view_with_filenames
        ActionView::Base.annotate_rendered_view_with_filenames = false
        block.call
      ensure
        ActionView::Base.annotate_rendered_view_with_filenames = old
      end
    end
  end
end
