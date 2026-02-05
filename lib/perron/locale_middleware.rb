# frozen_string_literal: true

module Perron
  class LocaleMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless Perron.configuration.locales.present?

      path = env["PATH_INFO"]

      # Only match locale if it's exactly at the start with /
      locale_match = path.match(%r{^/([a-z]+)(?:/|$)})
      requested_locale = locale_match ? locale_match[1] : nil

      available = Perron.configuration.locales.map(&:to_s)
      default = (Perron.configuration.default_locale || Perron.configuration.locales.first).to_s

      locale = if requested_locale && requested_locale != "" && available.include?(requested_locale)
        requested_locale.to_sym
      else
        default.to_sym
      end

      I18n.locale = locale
      Thread.current[:perron_locale] = locale

      @app.call(env)
    end
  end
end
