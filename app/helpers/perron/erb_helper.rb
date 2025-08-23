# frozen_string_literal: true

module Perron
  module ErbHelper
    def erbify(content = nil, options = {}, &block)
      Perron::Resource::Renderer.erb(content || capture(&block).strip_heredoc, {resource: @resource})
    end
  end
end
