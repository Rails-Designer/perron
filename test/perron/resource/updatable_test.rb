require "test_helper"

class Perron::Resource::UpdatableTest < ActiveSupport::TestCase
  FIXTURE = "test/dummy/app/content/posts/2023-05-15-sample-post.md"

  def setup
    @tmp = Rails.root.join("tmp/updatable_metadata_#{SecureRandom.hex(4)}.md").to_s
    FileUtils.cp(FIXTURE, @tmp)
    @post = Content::Post.new(@tmp)
  end

  def teardown
    FileUtils.rm_f(@tmp)
  end

  def original_frontmatter
    Perron::Resource::Separator.new(File.read(FIXTURE)).frontmatter.to_h
  end

  def current_frontmatter
    Perron::Resource::Separator.new(File.read(@tmp)).frontmatter.to_h
  end

  def original_body
    Perron::Resource::Separator.new(File.read(FIXTURE)).content
  end

  def current_body
    Perron::Resource::Separator.new(File.read(@tmp)).content
  end

  test "updating an existing key changes only that key" do
    @post.metadata.update(title: "Changed Title")

    updated = current_frontmatter
    original = original_frontmatter

    assert_equal "Changed Title", updated[:title]
    assert_equal original.except(:title), updated.except(:title)
    assert_equal original_body, current_body
  end

  test "only the changed key line differs in the file" do
    @post.metadata.update(title: "Changed Title")

    original_lines = File.readlines(FIXTURE)
    updated_lines = File.readlines(@tmp)

    diff = original_lines.zip(updated_lines).reject { |a, b| a == b }
    assert_equal 1, diff.size
    assert_match(/^title: Changed Title$/, diff.first.last)
  end

  test "updating a new key inserts it without disturbing others" do
    @post.metadata.update(published_at: Date.new(2024, 1, 1))

    updated = current_frontmatter
    original = original_frontmatter

    assert_equal Date.new(2024, 1, 1), updated[:published_at]
    assert_equal original, updated.except(:published_at)
    assert_equal original_body, current_body
  end

  test "multiline values round-trip without altering other keys" do
    @post.metadata.update(description: "line one\nline two")

    updated = current_frontmatter
    original = original_frontmatter

    assert_equal "line one\nline two", updated[:description]
    assert_equal original.except(:description), updated.except(:description)
    assert_equal original_body, current_body
  end

  test "in-memory metadata reflects the update immediately" do
    @post.metadata.update(title: "In Memory")

    assert_equal "In Memory", @post.metadata.title
  end

  test "update returns self for chaining" do
    assert_equal @post.metadata, @post.metadata.update(title: "X")
  end
end
