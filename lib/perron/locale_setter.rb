# frozen_string_literal: true

module Perron
  module LocaleSetter
    extend ActiveSupport::Concern

    included do
      before_action :set_perron_locale, prepend: true
    end

    private

    def set_perron_locale
      return unless Perron.configuration.locales.present?

      available = Perron.configuration.locales.map(&:to_s)
      default = (Perron.configuration.default_locale || Perron.configuration.locales.first).to_s

      requested = params[:locale].to_s

      if available.include?(requested)
        locale = requested.to_sym
      else
        locale = default.to_sym
      end

      I18n.locale = locale
      default_url_options[:locale] = locale
      Thread.current[:perron_locale] = locale
    end
  end
end
