require "test_helper"

class Perron::BuildHooksTest < ActiveSupport::TestCase
  test "configuration has before_build callback" do
    assert_respond_to Perron.configuration, :before_build
  end

  test "configuration has after_build callback" do
    assert_respond_to Perron.configuration, :after_build
  end

  test "before_build failure aborts build" do
    Perron.configure do |config|
      config.before_build = ->(context) { raise "pre-build validation failed" }
    end

    assert_raises(RuntimeError) do
      Perron::Site.build
    end
  end
end