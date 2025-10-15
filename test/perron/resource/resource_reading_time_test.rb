require "test_helper"

class Perron::Resource::ReadingTimeTest < ActiveSupport::TestCase
  setup { @post_resource = Content::Post.new("test/dummy/app/content/posts/2023-05-15-sample-post.md") }

  test "#estimated_reading_time returns total minutes without format" do
    result = @post_resource.estimated_reading_time(format: nil)

    assert_kind_of Integer, result
    assert_operator result, :>=, 1
  end

  test "#estimated_reading_time returns formatted string with default format" do
    result = @post_resource.estimated_reading_time

    assert_kind_of String, result
    assert_match(/\d+ min read/, result)
  end

  test "#estimated_reading_time accepts custom wpm" do
    slow_read = @post_resource.estimated_reading_time(wpm: 100, format: nil)
    fast_read = @post_resource.estimated_reading_time(wpm: 300, format: nil)

    assert_operator slow_read, :>, fast_read
  end

  test "#estimated_reading_time accepts custom format with minutes" do
    result = @post_resource.estimated_reading_time(format: "%{minutes} minutes")

    assert_match(/\d+ minutes/, result)
  end

  test "#estimated_reading_time accepts custom format with hours" do
    result = @post_resource.estimated_reading_time(format: "%{hours}h %{minutes}m")

    assert_match(/\d+h \d+m/, result)
  end

  test "#estimated_reading_time accepts custom format with seconds" do
    result = @post_resource.estimated_reading_time(format: "%{seconds}s")

    assert_match(/\d+s/, result)
  end

  test "#estimated_reading_time supports short-form aliases" do
    result = @post_resource.estimated_reading_time(format: "%{h}:%{min}:%{s}")

    assert_match(/\d+:\d+:\d+/, result)
  end

  test "#estimated_reading_time has minimum of 1 minute" do
    result = @post_resource.estimated_reading_time(wpm: 999999, format: nil)

    assert_equal 1, result
  end

  test "#reading_time is an alias for estimated_reading_time" do
    assert_equal @post_resource.estimated_reading_time, @post_resource.reading_time
  end
end
