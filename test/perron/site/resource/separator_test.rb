require "test_helper"

class Perron::Site::Resource::SeparatorTest < ActiveSupport::TestCase
  def test_parses_frontmatter_and_content
    content = <<~CONTENT
      ---
      title: Test Title
      date: 2023-05-15
      ---
      This is the actual content.
    CONTENT
    separator = Perron::Resource::Separator.new(content)

    assert_equal "This is the actual content.", separator.content
    assert_equal "Test Title", separator.metadata.title
    assert_equal Date.new(2023, 5, 15), separator.metadata.date
  end

  def test_handles_content_without_frontmatter
    content = "Just plain content with no frontmatter"
    separator = Perron::Resource::Separator.new(content)

    assert_equal content, separator.content
    assert_empty separator.metadata.to_h
  end

  def test_handles_empty_frontmatter
    content = <<~CONTENT
      ---
      ---
      Content with empty frontmatter
    CONTENT
    separator = Perron::Resource::Separator.new(content)

    assert_equal "Content with empty frontmatter", separator.content
    assert_empty separator.metadata.to_h
  end
end
