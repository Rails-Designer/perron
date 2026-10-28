require "test_helper"

class Perron::EngineTest < ActiveSupport::TestCase
  test "does not mount the concierge command route outside development" do
    assert_not Rails.application.routes.named_routes.key?(:perron_run_command)
  end
end
