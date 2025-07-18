module Perron
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_initializer
      template "initializer.rb.tt", "config/initializers/perron.rb"
    end
  end
end
