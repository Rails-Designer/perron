# frozen_string_literal: true

module Perron
  class Engine < Rails::Engine
    initializer "perron.default_url_options" do |app|
      app.config.action_controller.default_url_options = Perron.configuration.default_url_options
    end

    rake_tasks do
      load File.expand_path("../tasks/perron.rake", __FILE__)
    end
  end
end
