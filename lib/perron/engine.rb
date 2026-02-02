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
      if Perron.configuration.hmr && Rails.env.development?
        app.config.middleware.insert_before(
          ActionDispatch::Static,
          Mata,
          watch: Perron.configuration.hmr_watch_paths,
          skip: Perron.configuration.hmr_skip_paths
        )
      end
    end

    rake_tasks do
      load File.expand_path("../tasks/build.rake", __FILE__)
      load File.expand_path("../tasks/clobber.rake", __FILE__)
      load File.expand_path("../tasks/sync_sources.rake", __FILE__)
      load File.expand_path("../tasks/validate.rake", __FILE__)
    end
  end
end
