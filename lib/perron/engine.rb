# frozen_string_literal: true

require "perron/output_server"
require "perron/development_feed_server"
require "mata"

module Perron
  class Engine < Rails::Engine
    initializer "perron.default_url_options" do |app|
      app.config.action_controller.default_url_options = Perron.configuration.default_url_options
    end

    initializer "perron.output_server" do |app|
      app.middleware.use Perron::OutputServer
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

    rake_tasks do
      load File.expand_path("../tasks/build.rake", __FILE__)
      load File.expand_path("../tasks/clobber.rake", __FILE__)
      load File.expand_path("../tasks/install.rake", __FILE__)
      load File.expand_path("../tasks/sync_sources.rake", __FILE__)
      load File.expand_path("../tasks/validate.rake", __FILE__)
    end
  end
end
