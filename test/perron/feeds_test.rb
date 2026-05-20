require "test_helper"

class Perron::FeedsTest < ActionDispatch::IntegrationTest
  setup do
    Content::Post.configure { it.feeds.rss.enabled = true }
    Content::Post.configure { it.feeds.atom.enabled = true }
    Content::Page.configure { it.feeds.rss.enabled = true }
  end

  teardown do
    Content::Post.configure { it.feeds.rss.enabled = false }
    Content::Post.configure { it.feeds.atom.enabled = false }
    Content::Page.configure { it.feeds.rss.enabled = false }
  end

  test "renders all enabled feeds by default" do
    document = rendered_document

    assert_select document, 'link[rel="alternate"][type="application/rss+xml"][title="Posts RSS Feed"][href*="feeds/posts.xml"]', count: 1
    assert_select document, 'link[rel="alternate"][type="application/atom+xml"][title="Posts Atom Feed"][href*="feeds/posts.atom"]', count: 1
    assert_select document, 'link[rel="alternate"][type="application/rss+xml"][title="Pages RSS Feed"][href*="feeds/pages.xml"]', count: 1

    assert_select document, 'link[href*="posts.json"]', count: 0
  end

  test "renders only specified collections using :only option" do
    document = rendered_document(only: [:posts])

    assert_select document, 'link[href*="feeds/posts.xml"]', count: 1, message: "Renders one RSS feeds"
    assert_select document, 'link[href*="feeds/posts.atom"]', count: 1, message: "Renders one Atom feed"
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
    Nokogiri::HTML::DocumentFragment.parse(Perron::Feeds.new.render(options))
  end
end
