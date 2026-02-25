require "test_helper"

class Perron::Site::Builder::Feeds::AtomTest < ActiveSupport::TestCase
  include ConfigurationHelper

  setup do
    @posts = Perron::Site.collection("posts")
    @builder = Perron::Site::Builder::Feeds::Atom.new(collection: @posts)
  end

  test "generates correct Atom string with entries sorted by date" do
    @posts.configuration.feeds.atom.stub(:max_items, 10) do
      atom = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal "Perron", atom.at_xpath("//generator").text
      assert_equal "http://localhost:3000/", atom.at_xpath("//generator").attributes["uri"].value
      assert_equal Perron::VERSION, atom.at_xpath("//generator").attributes["version"].value
      assert_equal "Dummy App", atom.at_xpath("//title").text
      assert_equal "", atom.at_xpath("//subtitle").text

      self_link = atom.at_xpath("//link[@rel='self']")
      assert_equal "application/atom+xml", self_link.attributes["type"].value

      alternate_link = atom.at_xpath("//link[@rel='alternate']")
      assert_equal "http://localhost:3000/", alternate_link.attributes["href"].value
      assert_equal "text/html", alternate_link.attributes["type"].value

      entries = atom.xpath("//entry")
      assert_operator entries.count, :>, 0, "Should include at least one post"

      published_dates = entries.xpath("published").map { Time.parse(it.text) }
      assert_equal published_dates.sort.reverse, published_dates, "Posts should be sorted by date descending"
    end
  end

  test "respects max_items configuration" do
    @posts.configuration.feeds.atom.stub(:max_items, 1) do
      atom = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal 1, atom.xpath("//entry").count
    end
  end

  test "configured feed name and description" do
    @posts.configuration.feeds.atom.stub(:title, "Custom Atom title") do
      atom = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal "Custom Atom title", atom.at_xpath("//title").text
    end

    @posts.configuration.feeds.atom.stub(:description, "Custom Atom description") do
      atom = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_equal "Custom Atom description", atom.at_xpath("//subtitle").text
    end
  end

  test "uses polymorphic links for entries" do
    @posts.configuration.feeds.atom.stub(:max_items, 1) do
      atom = Nokogiri::XML(@builder.generate).remove_namespaces!

      link = atom.at_xpath("//entry/link[@rel='alternate']").attributes["href"].value
      assert_match %r{^http://localhost:3000/blog/.+/$}, link, "Should be a valid blog post URL"
    end
  end

  test "includes author when present" do
    @posts.configuration.feeds.atom.stub(:max_items, 10) do
      atom = Nokogiri::XML(@builder.generate).remove_namespaces!

      entry_with_author = atom.xpath("//entry").find do |entry|
        entry.at_xpath("title").text == "Sample Post"
      end

      assert_not_nil entry_with_author, "Sample Post should exist in feed"
      author_name = entry_with_author.at_xpath("author/name")
      author_email = entry_with_author.at_xpath("author/email")

      assert_equal "Rails Designer", author_name.text
      assert_equal "support@railsdesigner.com", author_email.text
    end
  end

  test "includes author from config when belongs_to author not defined" do
    @posts.configuration.feeds.atom.stub(:max_items, 10) do
      atom = Nokogiri::XML(@builder.generate).remove_namespaces!

      entries_with_config_author = atom.xpath("//entry").select do |entry|
        author_name = entry.at_xpath("author/name")&.text
        author_name == "Atom Config Author"
      end

      assert_operator entries_with_config_author.count, :>, 0, "Should have at least one post using config author"
    end
  end

  test "includes required id elements" do
    @posts.configuration.feeds.atom.stub(:max_items, 1) do
      atom = Nokogiri::XML(@builder.generate).remove_namespaces!

      assert_not_nil atom.at_xpath("//id"), "Feed should have id element"
      assert_not_nil atom.at_xpath("//entry/id"), "Entry should have id element"
    end
  end

  test "includes content with correct type" do
    @posts.configuration.feeds.atom.stub(:max_items, 1) do
      atom = Nokogiri::XML(@builder.generate).remove_namespaces!

      content = atom.at_xpath("//entry/content")
      assert_equal "html", content.attributes["type"].value
    end
  end

  test "sets a `ref` param to the link" do
    @posts.configuration.feeds.atom.stub(:ref, "perron.railsdesigner.com") do
      @posts.configuration.feeds.atom.stub(:max_items, 1) do
        atom = Nokogiri::XML(@builder.generate).remove_namespaces!

        link = atom.at_xpath("//entry/link[@rel='alternate']").attributes["href"].value
        assert_match %r{\?ref=perron\.railsdesigner\.com$}, link, "Should include ref parameter"
      end
    end
  end
end
