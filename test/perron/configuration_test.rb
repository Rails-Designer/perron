require "test_helper"

class Perron::ConfigurationTest < ActiveSupport::TestCase
  test "output_server_strict defaults to true in standalone mode" do
    config = Perron::Configuration.new
    config.mode = :standalone

    assert_equal true, config.output_server_strict
  end

  test "output_server_strict defaults to false in integrated mode" do
    config = Perron::Configuration.new
    config.mode = :integrated

    assert_equal false, config.output_server_strict
  end

  test "explicit output_server_strict overrides the mode default" do
    standalone = Perron::Configuration.new
    standalone.mode = :standalone
    standalone.output_server_strict = false
    assert_equal false, standalone.output_server_strict

    integrated = Perron::Configuration.new
    integrated.mode = :integrated
    integrated.output_server_strict = true
    assert_equal true, integrated.output_server_strict
  end

  test "output resolves to public in integrated mode and to the configured value otherwise" do
    assert_equal "public", Perron::Configuration.new.tap { it.mode = :integrated }.output
    assert_equal "output", Perron::Configuration.new.tap { it.mode = :standalone }.output
  end
end
