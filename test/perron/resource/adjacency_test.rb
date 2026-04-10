require "test_helper"

class Perron::Resource::AdjacencyTest < ActiveSupport::TestCase
  test "next returns the following resource within same section" do
    installation = Content::Article.find("installation")
    quickstart = Content::Article.find("quickstart")

    assert_equal quickstart.id, installation.next.id
  end

  test "previous returns the previous resource within same section" do
    quickstart = Content::Article.find("quickstart")
    installation = Content::Article.find("installation")

    assert_equal installation.id, quickstart.previous.id
  end

  test "next returns nil for the last resource" do
    changelog = Content::Article.find("changelog")

    assert_nil changelog.next
  end

  test "previous returns nil for the first resource" do
    installation = Content::Article.find("installation")

    assert_nil installation.previous
  end

  test "next cross-category: last of getting_started goes to first of content" do
    quickstart = Content::Article.find("quickstart")
    configuration = Content::Article.find("configuration")

    assert_equal configuration.id, quickstart.next.id
  end

  test "previous cross-category: first of content goes to last of getting_started" do
    configuration = Content::Article.find("configuration")
    quickstart = Content::Article.find("quickstart")

    assert_equal quickstart.id, configuration.previous.id
  end

  test "next cross-category: last of content goes to first of metadata" do
    advanced = Content::Article.find("advanced")
    changelog = Content::Article.find("changelog")

    assert_equal changelog.id, advanced.next.id
  end

  test "previous cross-category: first of metadata goes to last of content" do
    changelog = Content::Article.find("changelog")
    advanced = Content::Article.find("advanced")

    assert_equal advanced.id, changelog.previous.id
  end

  test "flat: next returns the following resource" do
    installation = Content::Doc.find("installation")
    quickstart = Content::Doc.find("quickstart")

    assert_equal quickstart.id, installation.next.id
  end

  test "flat: next returns nil for the last resource" do
    quickstart = Content::Doc.find("quickstart")

    assert_nil quickstart.next
  end

  test "flat: previous returns previous in natural order" do
    installation = Content::Doc.find("installation")
    configuration = Content::Doc.find("configuration")

    assert_equal configuration.id, installation.previous.id
  end

  test "alphabetical: groups by section and orders sections alphabetically" do
    configuration = Content::Changelog.find("configuration")
    advanced = Content::Changelog.find("advanced")

    assert_equal advanced.id, configuration.next.id
  end

  test "alphabetical: previous returns nil for first section, first item" do
    configuration = Content::Changelog.find("configuration")

    assert_nil configuration.previous
  end
end
