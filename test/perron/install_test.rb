require "test_helper"
require "rails/generators/rails/app/app_generator"

class InstallTaskTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  test "creates perron initializer" do
    with_new_rails_app do
      run_command("bin/rails", "perron:install")

      assert File.exist?("config/initializers/perron.rb")
      assert_match(/Perron.configure do |config|/, File.read("config/initializers/perron.rb"))
    end
  end

  test "creates data folder with README" do
    with_new_rails_app do
      run_command("bin/rails", "perron:install")

      assert File.exist?("app/content/data/README.md")
      content = File.read("app/content/data/README.md")
      assert_match(/<% Content::Data::Features.all.each do |feature| %>/, content)
      assert_match(/<%= render Content::Data::Features.all %>/, content)
    end
  end

  test "adds markdown gem options to Gemfile" do
    with_new_rails_app do
      run_command("bin/rails", "perron:install")

      assert_match(/# gem "commonmarker"/, File.read("Gemfile"))
      assert_match(/# gem "kramdown"/, File.read("Gemfile"))
      assert_match(/# gem "redcarpet"/, File.read("Gemfile"))
    end
  end

  test "adds output folder to gitignore" do
    with_new_rails_app do
      run_command("bin/rails", "perron:install")

      assert_match(%r{/#{Perron.configuration.output}/}, File.read(".gitignore"))
    end
  end

  private

  def with_new_rails_app
    Rails.app_class = nil
    Rails.application = nil

    Dir.mktmpdir do |tmpdir|
      app_dir = "#{tmpdir}/dummy_app"

      Rails::Generators::AppGenerator.start([app_dir, "--quiet", "--skip-bundle", "--skip-bootsnap"])

      Dir.chdir(app_dir) do
        gemfile = File.read("Gemfile")
        gemfile << %(gem "perron", path: #{File.expand_path("../..", __dir__).inspect}\n)
        File.write("Gemfile", gemfile)

        run_command("bundle", "install")

        yield(app_dir)
      end
    end
  end

  def run_command(*command)
    Bundler.with_unbundled_env do
      capture_subprocess_io { system(*command, exception: true) }
    end
  end
end
