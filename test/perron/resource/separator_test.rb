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
    assert_equal "Test Title", separator.frontmatter.title
    assert_equal Date.new(2023, 5, 15), separator.frontmatter.date
  end

  def test_handles_content_without_frontmatter
    content = "Just plain content with no frontmatter"
    separator = Perron::Resource::Separator.new(content)

    assert_equal content, separator.content
    assert_empty separator.frontmatter.to_h
  end

  def test_handles_empty_frontmatter
    content = <<~CONTENT
      ---
      ---
      Content with empty frontmatter
    CONTENT
    separator = Perron::Resource::Separator.new(content)

    assert_equal "Content with empty frontmatter", separator.content
    assert_empty separator.frontmatter.to_h
  end

  def test_parses_inline_array_syntax
    content = <<~CONTENT
      ---
      authors: [alice, bob]
      ---
      Content
    CONTENT
    separator = Perron::Resource::Separator.new(content)
    assert_equal ["alice", "bob"], separator.frontmatter.authors
  end

  def test_parses_yaml_list_syntax
    content = <<~CONTENT
      ---
      authors:
        - alice
        - bob
      ---
      Content
    CONTENT
    separator = Perron::Resource::Separator.new(content)
    assert_equal ["alice", "bob"], separator.frontmatter.authors
  end

  def test_parses_mixed_types_in_frontmatter
    content = <<~CONTENT
      ---
      title: Hello
      tags: [ruby, yaml]
      categories:
        - tech
        - tutorial
      ---
      Content
    CONTENT
    separator = Perron::Resource::Separator.new(content)

    assert_equal "Hello", separator.frontmatter.title
    assert_equal ["ruby", "yaml"], separator.frontmatter.tags
    assert_equal ["tech", "tutorial"], separator.frontmatter.categories
  end
end
