# frozen_string_literal: true

module Perron
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc "Install Perron in your Rails app"

    def copy_initializer
      template "initializer.rb.tt", "config/initializers/perron.rb"
    end

    def create_data_directory
      template "README.md.tt", "app/content/data/README.md"
    end

    def add_markdown_gems
      append_to_file "Gemfile", <<~RUBY

        # Perron supports Markdown rendering using one of the following gems.
        # Uncomment your preferred choice and run `bundle install`
        # gem "commonmarker"
        # gem "kramdown"
        # gem "redcarpet"
      RUBY
    end

    def gitignore_output_folder
      append_to_file ".gitignore", "/#{Perron.configuration.output}/\n"
    end
  end
end
