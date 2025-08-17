# frozen_string_literal: true

require "test_helper"

class Perron::FeedsHelperTest < Minitest::Test
  include FeedsHelper

  def test_feeds_calls_feeds_correctly
    called = false
    options_received = nil
    original_new = Perron::Feeds.method(:new)

    Perron::Feeds.define_singleton_method(:new) do
      called = true

      Object.new.tap do |object|
        def object.render(options)
          @options = options

          "test result"
        end

        def object.options = @options
      end
    end

    options = {title: "Test Title"}
    result = feeds(options)
    options_received = result == "test result" ? options : nil

    Perron::Feeds.singleton_class.send(:remove_method, :new)
    Perron::Feeds.define_singleton_method(:new, original_new)

    assert called, "Perron::Feeds.new was not called"
    assert_equal options, options_received
  end
end
