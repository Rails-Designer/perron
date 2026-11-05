require "test_helper"

class Perron::Resource::AdjacencyTest < ActiveSupport::TestCase
  test "next returns the following resource within same section" do
    installation = Content::Article.find!("installation")
    quickstart = Content::Article.find!("quickstart")

    assert_equal quickstart.id, installation.next.id
  end

  test "previous returns the previous resource within same section" do
    quickstart = Content::Article.find!("quickstart")
    installation = Content::Article.find!("installation")

    assert_equal installation.id, quickstart.previous.id
  end

  test "next returns nil for the last resource" do
    changelog = Content::Article.find!("changelog")

    assert_nil changelog.next
  end

  test "previous returns nil for the first resource" do
    installation = Content::Article.find!("installation")

    assert_nil installation.previous
  end

  test "next cross-category: last of getting_started goes to first of content" do
    quickstart = Content::Article.find!("quickstart")
    configuration = Content::Article.find!("configuration")

    assert_equal configuration.id, quickstart.next.id
  end

  test "previous cross-category: first of content goes to last of getting_started" do
    configuration = Content::Article.find!("configuration")
    quickstart = Content::Article.find!("quickstart")

    assert_equal quickstart.id, configuration.previous.id
  end

  test "next cross-category: last of content goes to first of metadata" do
    advanced = Content::Article.find!("advanced")
    changelog = Content::Article.find!("changelog")

    assert_equal changelog.id, advanced.next.id
  end

  test "previous cross-category: first of metadata goes to last of content" do
    changelog = Content::Article.find!("changelog")
    advanced = Content::Article.find!("advanced")

    assert_equal advanced.id, changelog.previous.id
  end

  test "flat: next returns the following resource by position" do
    installation = Content::Doc.find!("installation")
    configuration = Content::Doc.find!("configuration")

    assert_equal configuration.id, installation.next.id
  end

  test "flat: next returns nil for the last resource" do
    quickstart = Content::Doc.find!("quickstart")

    assert_nil quickstart.next
  end

  test "flat: previous returns the preceding resource by position" do
    installation = Content::Doc.find!("installation")
    configuration = Content::Doc.find!("configuration")

    assert_equal installation.id, configuration.previous.id
    assert_nil installation.previous
  end

  test "alphabetical: groups by section and orders sections alphabetically" do
    configuration = Content::Changelog.find!("configuration")
    advanced = Content::Changelog.find!("advanced")

    assert_equal advanced.id, configuration.next.id
  end

  test "alphabetical: previous returns nil for first section, first item" do
    configuration = Content::Changelog.find!("configuration")

    assert_nil configuration.previous
  end

  test "ordered grouping: a resource without the grouping field sorts last instead of raising" do
    resource_class = Class.new do
      include Perron::Resource::Adjacency

      attr_reader :id, :section, :position

      def initialize(id, section, position)
        @id = id
        @section = section
        @position = position
      end

      def self.all
        @all ||= [new("first", "intro", 1), new("second", "guide", 1), new("ungrouped", nil, 1)]
      end

      adjacent_by :position, within: {section: %w[intro guide]}
    end

    first, second, ungrouped = resource_class.all

    assert_equal second.id, first.next.id
    assert_equal ungrouped.id, second.next.id
    assert_nil ungrouped.next
    assert_equal second.id, ungrouped.previous.id
  end

  test "without within: orders by the position method instead of the collection order" do
    resource_class = Class.new do
      include Perron::Resource::Adjacency

      attr_reader :id, :position

      def initialize(id, position)
        @id = id
        @position = position
      end

      def self.all
        @all ||= [new("third", 3), new("first", 1), new("second", 2)]
      end

      adjacent_by :position
    end

    third, first, second = resource_class.all

    assert_equal second.id, first.next.id
    assert_equal third.id, second.next.id
    assert_nil third.next
    assert_equal first.id, second.previous.id
    assert_nil first.previous
  end
end
