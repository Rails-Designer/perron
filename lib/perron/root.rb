# frozen_string_literal: true

module Perron
  module Root
    include ActiveSupport::Concern

    def root
      @resource = Content::Page.find("/")

      render :show
    end
  end
end
