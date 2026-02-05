# frozen_string_literal: true

require "perron/output_server"
require "perron/development_feed_server"
require "mata"

module Perron
  class Engine < Rails::Engine
    initializer "perron.default_url_options" do |app|
      app.config.action_controller.default_url_options = Perron.configuration.default_url_options
    end

    require "perron/locale_middleware"

    initializer "perron.i18n_setup" do
      if Perron.configuration.locales.present?
        I18n.enforce_available_locales = false
        I18n.available_locales ||= []
        I18n.available_locales.concat(Perron.configuration.locales.map(&:to_sym))
        I18n.default_locale = Perron.configuration.default_locale || Perron.configuration.locales.first
      end
    end

    config.after_initialize do
      require "perron/locale_setter"

      ActiveSupport.on_load(:action_controller) do
        include Perron::LocaleSetter
      end
    end

    initializer "perron.locale_middleware" do |app|
      app.middleware.use Perron::LocaleMiddleware if Perron.configuration.locales.present?
    end

    initializer "perron.output_server" do |app|
      app.middleware.use Perron::OutputServer if Rails.env.development?
    end

    initializer "perron.development_feed_server" do |app|
      app.middleware.use Perron::DevelopmentFeedServer if Rails.env.development?
    end

    initializer "perron.configure_hmr", after: :load_config_initializers do |app|
      if Rails.env.development? && Perron.configuration.live_reload
        app.config.middleware.insert_before(
          ActionDispatch::Static,
          Mata,
          watch: Perron.configuration.live_reload_watch_paths,
          skip: Perron.configuration.live_reload_skip_paths
        )
      end
    end

    initializer "perron.concierge", before: :add_builtin_route do |app|
      app.config.after_initialize do
        app.routes.append do
          namespace :perron do
            post :run_command, to: "concierge#run_command"
          end

          root to: "perron/concierge#show" unless app.routes.named_routes.key?(:root)
        end
      end

      app.routes.finalize!
    end

    initializer "perron.inflections" do
      ActiveSupport::Inflector.inflections(:en) do |inflect|
        inflect.acronym "RSS"
        inflect.acronym "Atom"
        inflect.acronym "Json"
      end
    end

    rake_tasks do
      load File.expand_path("../tasks/build.rake", __FILE__)
      load File.expand_path("../tasks/clobber.rake", __FILE__)
      load File.expand_path("../tasks/install.rake", __FILE__)
      load File.expand_path("../tasks/sync_sources.rake", __FILE__)
      load File.expand_path("../tasks/validate.rake", __FILE__)
    end
  end
end
