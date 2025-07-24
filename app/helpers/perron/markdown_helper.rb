# frozen_string_literal: true

require "perron/markdown"

module Perron
  module MarkdownHelper
    def markdownify(content = nil, options = {}, &block)
      processors = options.fetch(:process, [])

      Perron::Markdown.render(content || capture(&block).strip_heredoc, processors: processors)
    end
  end
end
