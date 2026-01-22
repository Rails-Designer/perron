# frozen_string_literal: true

require "perron/markdown"

module Perron
  module MarkdownHelper
    def markdownify(content = nil, process: [], &block)
      text = block_given? ? capture(&block).strip_heredoc : content

      Perron::Markdown.render(text, processors: process)
    end
  end
end
