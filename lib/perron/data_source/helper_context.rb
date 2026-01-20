# frozen_string_literal: true

module Perron
  class DataSource < SimpleDelegator
    class HelperContext
      include Singleton

      def initialize
        self.class.include ActionView::Helpers::AssetUrlHelper
        self.class.include ActionView::Helpers::DateHelper
        self.class.include Rails.application.routes.url_helpers
      end

      def get_binding = binding

      def default_url_options = Perron.configuration.default_url_options || {}
    end
    private_constant :HelperContext
  end
end
