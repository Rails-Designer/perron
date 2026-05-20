# frozen_string_literal: true

require "perron/markdown"

module Perron
  module MarkdownHelper
    def markdownify(content = nil, process: nil, resource: nil, &block)
      text = block_given? ? capture(&block).strip_heredoc : content
      processors = (process.nil? || process.empty?) ? Perron.configuration.default_processors : process

      Perron::Markdown.render(text, processors: processors, resource: resource || @resource)
    end
  end
end
