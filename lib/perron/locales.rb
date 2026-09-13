# frozen_string_literal: true

module Perron
  module Locales
    module_function

    def enabled?
      available_locales.many?
    end

    def available_locales
      Rails.application.config.i18n.available_locales.presence || [I18n.default_locale]
    end

    def default_locale
      Rails.application.config.i18n.default_locale || I18n.default_locale
    end

    def constraint
      Regexp.union(available_locales.map(&:to_s))
    end

    def prefix_default_locale?
      Perron.configuration.i18n.prefix_default_locale
    end

    def url_options
      url_options_for(I18n.locale.to_sym)
    end

    def url_options_for(locale)
      if prefix_default_locale? || locale != default_locale.to_sym
        {locale: locale.to_sym}
      else
        {locale: nil}
      end
    end

    def localized_path(path)
      return path unless enabled? && (prefix_default_locale? || I18n.locale.to_s != default_locale.to_s)

      File.join(I18n.locale.to_s, path)
    end
  end
end
