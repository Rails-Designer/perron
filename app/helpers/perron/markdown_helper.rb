# frozen_string_literal: true

require "perron/markdown"

module Perron
  module MarkdownHelper
    def markdownify(content = nil, &block) = Perron::Markdown.render(content || capture(&block).strip_heredoc)
  end
end
