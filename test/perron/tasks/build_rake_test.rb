require "test_helper"
require "rake"

class BuildTest < ActiveSupport::TestCase
  setup do
    unless Rake::Task.task_defined?("perron:build")
      Rake::Task.define_task("assets:precompile")
      Rake::Task.define_task(:environment)

      load File.expand_path("../../../lib/perron/tasks/build.rake", __dir__)
    end

    @original_rails_env = Rails.env
  end

  teardown do
    Rails.env = @original_rails_env

    Rake::Task["perron:build"].reenable
  end

  test "warns when not running in production" do
    Rails.env = "development"

    output = capture_io do
      Perron::Site.stub(:build, nil) do
        Rake::Task["perron:build"].invoke
      end
    end.first

    assert_match "RAILS_ENV=production bin/rails perron:build", output
  end

  test "does not warn when running in production" do
    Rails.env = "production"

    output = capture_io do
      Perron::Site.stub(:build, nil) do
        Rake::Task["perron:build"].invoke
      end
    end.first

    assert_empty output
  end
end
