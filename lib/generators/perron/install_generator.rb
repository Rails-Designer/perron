module Perron
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_initializer
      template "initializer.rb.tt", "config/initializers/perron.rb"
    end

    def create_data_directory
      data_directory = Rails.root.join("app", "views", "content", "data")
      empty_directory data_directory

      template "README.md.tt", File.join(data_directory, "README.md")
    end
  end
end
