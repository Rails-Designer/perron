# frozen_string_literal: true

module FeedsHelper
  def feeds(options = {}) = Perron::Feeds.new.render(options)
end
