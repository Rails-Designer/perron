# frozen_string_literal: true

module Perron
  module Root
    include ActiveSupport::Concern

    def root
      @resource = Content::Page.root

      render :show
    end
  end
end
