# frozen_string_literal: true

module FeedsHelper
  def feeds(options = {}) = Perron::Feeds.new(Perron::Site.collections).render(options)
end
