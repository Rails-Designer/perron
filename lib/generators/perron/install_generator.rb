# frozen_string_literal: true

module Perron
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_initializer
      template "initializer.rb.tt", "config/initializers/perron.rb"
    end

    def create_data_directory
      data_directory = Rails.root.join("app", "content", "data")
      empty_directory data_directory

      template "README.md.tt", File.join(data_directory, "README.md")
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
  end
end
