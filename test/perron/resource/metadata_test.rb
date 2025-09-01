require "test_helper"

class Perron::Resource::MetadataTest < ActiveSupport::TestCase
  include ConfigurationHelper

  def setup
    @post = Content::Post.new("test/dummy/app/content/posts/2023-05-15-sample-post.md")
    @post_frontmatter = Perron::Resource::Separator.new(@post.raw_content).frontmatter
    @posts_collection = Perron::Site.collection("posts")

    @custom_page = Content::Page.new("test/dummy/app/content/pages/custom.md")
    @custom_page_frontmatter = Perron::Resource::Separator.new(@custom_page.raw_content).frontmatter
    @pages_collection = Perron::Site.collection("pages")

    @root_page = Content::Page.new("test/dummy/app/content/pages/root.erb")
    @root_page_frontmatter = Perron::Resource::Separator.new(@root_page.raw_content).frontmatter

    @about_page = Content::Page.new("test/dummy/app/content/pages/about.md")
    @about_page_frontmatter = Perron::Resource::Separator.new(@about_page.raw_content).frontmatter
  end

  test "generates basic metadata with fallbacks for a standard blog post" do
    metadata = Perron::Resource::Metadata.new(
      resource: @post,
      frontmatter: @post_frontmatter,
      collection: @posts_collection
    ).data

    assert_equal "Sample Post", metadata.title
    assert_equal "Describing sample post", metadata.description

    assert_equal "http://localhost:3000/blog/sample-post/", metadata.og_url
    assert_equal Date.new(2023, 5, 15).to_datetime, metadata.article_published_time

    assert_equal "Dummy App", metadata.og_site_name

    assert_equal "summary_large_image", metadata.twitter_card

    assert_equal "Sample Post", metadata.og_title
    assert_equal "Sample Post", metadata.twitter_title
    assert_equal "Describing sample post", metadata.og_description
    assert_equal "Describing sample post", metadata.twitter_description
  end

  test "frontmatter values take precedence over all defaults and fallbacks" do
    metadata = Perron::Resource::Metadata.new(
      resource: @custom_page,
      frontmatter: @custom_page_frontmatter,
      collection: @pages_collection
    ).data

    assert_equal "Custom OG Title For Sharing", metadata.title
    assert_equal "Custom OG Title For Sharing", metadata.og_title, "og_title should be from frontmatter, not a fallback"
    assert_equal "summary", metadata.twitter_card, "twitter_card should be from frontmatter, not the default"

    assert_equal "/image.jpg", metadata.image
    assert_equal "/og-image.jpg", metadata.og_image, "og_image should be from frontmatter, not a fallback from image"
    assert_equal "/og-image.jpg", metadata.twitter_image, "twitter_image should fall back to the specific og_image"
  end

  test "inherits metadata from collection configuration" do
    collection = Perron::Site.collection("posts")
    metadata = Perron::Resource::Metadata.new(
      resource: @post,
      frontmatter: @post_frontmatter,
      collection: collection
    ).data

    assert_equal "The Post Collection Team", metadata.author
    assert_equal "The Post Collection Team", metadata.og_author, "og_author should fall back to collection author"
    assert_equal "article", metadata.type
    assert_equal "article", metadata.og_type, "og_type should fall back to collection type"
  end

  test "inherits and merges metadata from site configuration" do
    Perron.configure do |config|
      config.metadata = { author: "The Dummy App Team", locale: "en_GB", description: "Site-wide description" }
    end

    metadata = Perron::Resource::Metadata.new(
      resource: @about_page,
      frontmatter: @about_page_frontmatter,
      collection: @pages_collection
    ).data

    assert_equal "The Dummy App Team", metadata.author
    assert_equal "en_GB", metadata.locale
    assert_equal "en_GB", metadata.og_locale

    assert_equal "This is the about page.", metadata.description
    assert_equal "This is the about page.", metadata.og_description
  end

  test "metadata precedence is frontmatter > collection > site" do
    resource = Content::Post.new("test/dummy/app/content/posts/2023-06-15-another-post.md")
    frontmatter = Perron::Resource::Separator.new(resource.raw_content).frontmatter

    Perron.configure do |config|
      config.metadata.author = "Site Author"
    end

    collection = Perron::Site.collection("posts")
    metadata = Perron::Resource::Metadata.new(resource: resource, frontmatter: frontmatter, collection: collection).data

    assert_equal "Kendall", metadata.author, "Frontmatter author should take highest precedence"
  end

  test "removes nil values from final data after processing" do
    metadata = Perron::Resource::Metadata.new(
      resource: @about_page,
      frontmatter: @about_page_frontmatter,
      collection: @pages_collection
    ).data

    assert_not metadata.key?(:image), "key :image should be removed"
    assert_not metadata.key?(:og_image), "key :og_image should be removed"
    assert_not metadata.key?(:twitter_image), "key :twitter_image should be removed"
    assert_not metadata.key?(:author), "key :author should be removed"
  end

  test "generates canonical url for root" do
    metadata = Perron::Resource::Metadata.new(
      resource: @root_page,
      frontmatter: @root_page_frontmatter,
      collection: @pages_collection
    ).data

    assert_equal "http://localhost:3000/", metadata.og_url
  end

  test "generates canonical url with trailing slash when configured" do
    metadata = Perron::Resource::Metadata.new(
      resource: @about_page,
      frontmatter: @about_page_frontmatter,
      collection: @pages_collection
    ).data

    assert_equal "http://localhost:3000/about/", metadata.og_url
  end

  test "title falls back to site name if not present anywhere" do
    metadata = Perron::Resource::Metadata.new(
      resource: @about_page,
      frontmatter: {},
      collection: @pages_collection
    ).data

    assert_equal "Dummy App", metadata.title, "Title should fall back to the configured site_name"
  end
end
