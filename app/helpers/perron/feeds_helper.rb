# frozen_string_literal: true

module Perron
  module FeedsHelper
    def feeds(options = {}) = Perron::Feeds.new.render(options)
  end
end
