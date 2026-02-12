# frozen_string_literal: true

require "perron/output_server"
require "mata"

module Perron
  class Engine < Rails::Engine
    initializer "perron.default_url_options" do |app|
      app.config.action_controller.default_url_options = Perron.configuration.default_url_options
    end

    initializer "perron.output_server" do |app|
      app.middleware.use Perron::OutputServer
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

    rake_tasks do
      load File.expand_path("../tasks/build.rake", __FILE__)
      load File.expand_path("../tasks/clobber.rake", __FILE__)
      load File.expand_path("../tasks/sync_sources.rake", __FILE__)
      load File.expand_path("../tasks/validate.rake", __FILE__)
      if defined?(BeamUp)
        load File.expand_path("../tasks/deploy.rake", __FILE__)
      end
    end
  end
end
