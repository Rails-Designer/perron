# frozen_string_literal: true

require "perron/locales"

module Perron
  module Localized
    extend ActiveSupport::Concern

    included do
      before_action :set_locale, if: -> { Perron::Locales.enabled? }
    end

    class Root
      def self.call(env) = new.call(env)

      def call(env)
        request = ActionDispatch::Request.new(env)

        root = Rails.application.routes.named_routes[:root]
        return not_found unless root&.defaults&.key?(:controller)

        controller = "#{root.defaults[:controller]}_controller".classify.constantize.new
        response = ActionDispatch::Response.create

        controller.dispatch(root.defaults[:action].to_sym, request, response)

        [response.status, response.headers, [response.body]]
      rescue NameError
        not_found
      end

      private

      def not_found = [404, {"Content-Type" => "text/plain"}, ["Not Found"]]
    end

    private

    def set_locale
      locale = params[:locale]&.to_sym

      I18n.locale = if locale && Perron::Locales.available_locales.include?(locale)
        locale
      else
        I18n.default_locale
      end
    end

    def default_url_options
      super.merge(Perron::Locales.url_options)
    end
  end
end
