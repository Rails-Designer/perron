require "test_helper"

class Perron::Resource::TableOfContentTest < ActiveSupport::TestCase
  setup do
    page_path = "test/dummy/app/content/pages/about.md"
    toc_resource_path = "test/dummy/app/content/other/toc-resource.html"
    toc_commonmarker_path = "test/dummy/app/content/other/toc-commonmarker.html"
    exclude_toc_resource_path = "test/dummy/app/content/other/exclude-toc-resource.html"

    @page = Content::Page.new(page_path)
    @toc_resource = Content::Page.new(toc_resource_path)
    @toc_commonmarker = Content::Page.new(toc_commonmarker_path)
    @exclude_toc_resource = Content::Page.new(exclude_toc_resource_path)
  end

  test "table_of_content returns empty array" do
    toc = @page.table_of_content

    assert_equal [], toc
  end

  test "table_of_content returns empty array when `toc: false`" do
    toc = @exclude_toc_resource.table_of_content

    assert_equal [], toc
  end

  test "table_of_content returns headings structure" do
    toc = @toc_resource.table_of_content

    assert_not_nil toc
    assert_equal 1, toc.size

    h1 = toc.first
    assert_equal "main-heading", h1.id
    assert_equal "Main Heading", h1.text
    assert_equal 1, h1.level
    assert_equal 2, h1.children.size

    h2_one = h1.children.first
    assert_equal "section-one", h2_one.id
    assert_equal "Section One", h2_one.text
    assert_equal 2, h2_one.level
    assert_equal 1, h2_one.children.size

    h2_two = h1.children.last
    assert_equal "section-two", h2_two.id
    assert_equal "Section Two", h2_two.text
    assert_equal 2, h2_two.level
    assert_equal 0, h2_two.children.size

    h3 = h2_one.children.first
    assert_equal "subsection", h3.id
    assert_equal "Subsection", h3.text
    assert_equal 3, h3.level
    assert_equal 0, h3.children.size
  end

  test "table_of_content returns headings structure for parsed commonmarker markdown" do
    assert_not_nil @toc_commonmarker.table_of_content
  end

  test "can limit heading levels" do
    toc_h1_only = @toc_resource.table_of_content(levels: %w[h1])
    assert_equal 1, toc_h1_only.size
    assert_equal 0, toc_h1_only.first.children.size

    toc_h1_h2 = @toc_resource.table_of_content(levels: %w[h1 h2])
    assert_equal 1, toc_h1_h2.size
    assert_equal 2, toc_h1_h2.first.children.size

    toc_h1_h2.first.children.each do |h2|
      assert_equal 0, h2.children.size
    end
  end

  test "table_of_contents is an alias for table_of_content" do
    assert_equal @toc_resource.table_of_content, @toc_resource.table_of_contents
  end

  test "toc is an alias for table_of_content" do
    assert_equal @toc_resource.table_of_content, @toc_resource.toc
  end
end
