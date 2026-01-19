require "test_helper"

class Perron::Site::Builder::Feeds::RssTest < ActiveSupport::TestCase
  include ConfigurationHelper

  setup do
    @posts = Perron::Site.collection("posts")
    @builder = Perron::Site::Builder::Feeds::Rss.new(collection: @posts)
  end

  test "generates correct RSS string with items sorted by date" do
    @posts.configuration.feeds.rss.stub(:max_items, 10) do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal "Perron (#{Perron::VERSION})", rss.at_xpath("//channel/generator").text
      assert_equal "Dummy App", rss.at_xpath("//channel/title").text
      assert_equal "", rss.at_xpath("//channel/description").text
      assert_equal "http://localhost:3000/", rss.at_xpath("//channel/link").text

      items = rss.xpath("//item")
      assert_operator items.count, :>, 0, "Should include at least one post"

      pub_dates = items.xpath("pubDate").map { Time.parse(it.text) }
      assert_equal pub_dates.sort.reverse, pub_dates, "Posts should be sorted by date descending"
    end
  end

  test "respects max_items configuration" do
    @posts.configuration.feeds.rss.stub(:max_items, 1) do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal 1, rss.xpath("//item").count
    end
  end

  test "configured feed name and description" do
    @posts.configuration.feeds.rss.stub(:title, "Custom RSS title") do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal "Custom RSS title", rss.at_xpath("//channel/title").text
    end

    @posts.configuration.feeds.rss.stub(:description, "Custom RSS description") do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal "Custom RSS description", rss.at_xpath("//channel/description").text
    end
  end

  test "uses polymorphic links for items" do
    @posts.configuration.feeds.rss.stub(:max_items, 1) do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      link = rss.at_xpath("//item/link").text
      assert_match %r{^http://localhost:3000/blog/.+/$}, link, "Should be a valid blog post URL"
    end
  end

  test "includes author when present" do
    @posts.configuration.feeds.rss.stub(:max_items, 10) do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      item_with_author = rss.xpath("//item").find do |item|
        item.at_xpath("title").text == "Sample Post"
      end

      assert_not_nil item_with_author, "Sample Post should exist in feed"
      author = item_with_author.at_xpath("author")
      assert_equal "support@railsdesigner.com (Rails Designer)", author.text
    end
  end

  test "includes author from config when belongs_to author not defined" do
    @posts.configuration.feeds.rss.stub(:max_items, 10) do
      rss = Nokogiri::XML(@builder.generate).remove_namespaces!

      items_with_config_author = rss.xpath("//item").select do |item|
        author = item.at_xpath("author")&.text
        author == "support@railsdesigner.com (RSS Config Author)"
      end

      assert_operator items_with_config_author.count, :>, 0, "Should have at least one post using config author"
    end
  end

  test "sets a `ref` param to the link" do
    @posts.configuration.feeds.rss.stub(:ref, "perron.railsdesigner.com") do
      @posts.configuration.feeds.rss.stub(:max_items, 1) do
        rss = Nokogiri::XML(@builder.generate).remove_namespaces!

        link = rss.at_xpath("//item/link").text
        assert_match %r{\?ref=perron\.railsdesigner\.com$}, link, "Should include ref parameter"
      end
    end
  end
end
