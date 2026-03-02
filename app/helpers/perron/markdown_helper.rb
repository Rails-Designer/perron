# frozen_string_literal: true

require "perron/markdown"

module Perron
  module MarkdownHelper
    def markdownify(content = nil, process: [], resource: nil, &block)
      text = block_given? ? capture(&block).strip_heredoc : content

      Perron::Markdown.render(text, processors: process, resource: resource || @resource)
    end
  end
end
