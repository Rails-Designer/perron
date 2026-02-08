require "test_helper"
require "rake"

class BuildTest < ActiveSupport::TestCase
  setup do
    unless Rake::Task.task_defined?("perron:set_production_env")
      Rake::Task.define_task("assets:precompile")
      Rake::Task.define_task(:environment)

      load File.expand_path("../../../lib/perron/tasks/build.rake", __dir__)
    end

    @original_rails_env = ENV["RAILS_ENV"]
  end

  teardown do
    ENV["RAILS_ENV"] = @original_rails_env

    Rake::Task["perron:set_production_env"].reenable
  end

  test "defaults RAILS_ENV to production when not set" do
    ENV.delete("RAILS_ENV")

    Rake::Task["perron:set_production_env"].invoke

    assert_equal "production", ENV["RAILS_ENV"]
  end

  test "does not override RAILS_ENV when already set" do
    ENV["RAILS_ENV"] = "staging"

    Rake::Task["perron:set_production_env"].invoke

    assert_equal "staging", ENV["RAILS_ENV"]
  end
end
