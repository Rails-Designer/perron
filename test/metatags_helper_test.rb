# frozen_string_literal: true

require "test_helper"

class MetaTagsHelperTest < Minitest::Test
  include MetaTagsHelper

  def setup
    @request = Minitest::Mock.new

    @request.expect :path, "/test-path"
  end

  def test_meta_tags_calls_metatags_correctly
    called = false
    resource_received = nil
    options_received = nil
    original_new = Perron::Metatags.method(:new)

    Perron::Metatags.define_singleton_method(:new) do |resource|
      called = true
      resource_received = resource

      Object.new.tap do |object|
        def object.render(options)
          @options = options

          "test result"
        end

        def object.options = @options
      end
    end

    options = {title: "Test Title"}
    result = meta_tags(options)
    options_received = result == "test result" ? options : nil

    Perron::Metatags.singleton_class.send(:remove_method, :new)
    Perron::Metatags.define_singleton_method(:new, original_new)

    assert called, "Perron::Metatags.new was not called"
    assert_equal "/test-path", resource_received&.path
    assert_equal options, options_received

    @request.verify
  end

  private

  def request = @request
end
