require "test_helper"
require "generators/perron/install_generator"

module Perron
  class InstallGeneratorTest < Rails::Generators::TestCase
    tests Perron::InstallGenerator

    destination File.expand_path("../../dummy/tmp/", __dir__)

    setup :prepare_destination
    setup :create_gemfile
    setup :create_empty_gitignore

    test "create perron initializer" do
      run_generator

      assert_file "config/initializers/perron.rb", /Perron.configure do |config|/
    end

    test "data folder creation" do
      run_generator

      assert_file "app/content/data/README.md"
    end

    test "adds (optional) markdown gem" do
      run_generator

      assert_file "Gemfile" do |content|
        assert_match(/# gem "commonmarker"/, content)
      end
    end

    private

    def create_gemfile
      gemfile_path = File.join(destination_root, "Gemfile")

      FileUtils.mkdir_p(File.dirname(gemfile_path))
      File.write(gemfile_path, "source 'https://rubygems.org'\n")
    end

    def create_empty_gitignore
      FileUtils.touch(File.join(destination_root, ".gitignore"))
    end
  end
end
