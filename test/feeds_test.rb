require "test_helper"

class Perron::FeedsTest < ActionDispatch::IntegrationTest
  setup do
    Content::Post.configure { |it| it.feeds.rss.enabled = true }
    Content::Page.configure { |it| it.feeds.rss.enabled = true }
  end

  teardown do
    Content::Post.configure { |it| it.feeds.rss.enabled = false }
    Content::Page.configure { |it| it.feeds.rss.enabled = false }
  end

  test "renders all enabled feeds by default" do
    document = rendered_document

    assert_select document, 'link[rel="alternate"][type="application/rss+xml"][title="Posts RSS Feed"][href*="feeds/posts.xml"]', count: 1
    assert_select document, 'link[rel="alternate"][href*="feeds/pages.xml"]', count: 1, message: "Could not find feed link for 'pages'. Ensure it is configured with an enabled feed in the dummy app."
    assert_select document, 'link[href*="posts.json"]', count: 0
  end

  test "renders only specified collections using :only option" do
    document = rendered_document(only: [:posts])

    assert_select document, 'link[href*="feeds/posts.xml"]', count: 1
    assert_select document, 'link[href*="feeds/pages.xml"]', count: 0, message: "Pages feed should be excluded"
  end

  test "renders all but specified collections using :except option" do
    document = rendered_document(except: [:posts])

    assert_select document, 'link[href*="feeds/pages.xml"]', count: 1
    assert_select document, 'link[href*="feeds/posts.xml"]', count: 0, message: "Posts feed should be excluded"
  end

  test "returns an empty document if no matching feeds are found" do
    document = rendered_document(only: [:nonexistent_collection])

    assert_select document, 'link', count: 0
  end

  private

  def rendered_document(options = {})
    Nokogiri::HTML::DocumentFragment.parse(Perron::Feeds.new(Perron::Site.collections).render(options))
  end
end
