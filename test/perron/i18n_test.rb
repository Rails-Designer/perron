# frozen_string_literal: true

require "test_helper"

class Perron::LocalesTest < ActiveSupport::TestCase
  test "reports i18n enabled when more than one locale is configured" do
    assert Perron::Locales.enabled?
  end

  test "available_locales reads the host application config.i18n" do
    assert_equal [:en, :nl], Perron::Locales.available_locales
  end

  test "default_locale reads the host application config.i18n" do
    assert_equal :en, Perron::Locales.default_locale
  end

  test "constraint builds a regexp from the available locales" do
    assert_equal Regexp.union("en", "nl"), Perron::Locales.constraint
  end

  test "localized_path prefixes paths for non-default locales" do
    I18n.with_locale(:nl) do
      assert_equal "nl/feeds/posts.atom", Perron::Locales.localized_path("feeds/posts.atom")
    end
  end

  test "localized_path keeps the default locale unprefixed" do
    I18n.with_locale(:en) do
      assert_equal "feeds/posts.atom", Perron::Locales.localized_path("feeds/posts.atom")
    end
  end

  test "localized_path prefixes the default locale when configured" do
    Perron.configuration.i18n.prefix_default_locale = true

    I18n.with_locale(:en) do
      assert_equal "en/feeds/posts.atom", Perron::Locales.localized_path("feeds/posts.atom")
    end
  ensure
    Perron.configuration.i18n.prefix_default_locale = false
  end

  test "url_options returns locale for non-default locales" do
    I18n.with_locale(:nl) do
      assert_equal({locale: :nl}, Perron::Locales.url_options)
    end
  end

  test "url_options returns nil-locale for the default locale" do
    I18n.with_locale(:en) do
      assert_equal({locale: nil}, Perron::Locales.url_options)
    end
  end
end

class Perron::Collection::LocaleResolutionTest < ActiveSupport::TestCase
  setup do
    @posts = Perron::Collection.new("posts")
    @authors = Perron::Collection.new("authors")
    @pages = Perron::Collection.new("pages")
  end

  teardown do
    I18n.locale = I18n.default_locale
  end

  test "resolves resources from the base directory for the default locale" do
    I18n.with_locale(:en) do
      file_paths = @posts.send(:load_resources).map { it.file_path }

      assert_includes file_paths, Rails.root.join("app/content/posts/2023-05-15-sample-post.md").to_s
      assert file_paths.none? { it.include?("/posts/nl/") }
    end
  end

  test "resolves localized files plus untranslated defaults for a non-default locale" do
    I18n.with_locale(:nl) do
      file_paths = @posts.send(:load_resources).map(&:file_path).map(&:to_s)

      assert_includes file_paths, Rails.root.join("app/content/posts/nl/2023-05-15-sample-post.md").to_s
      assert_includes file_paths, Rails.root.join("app/content/posts/2023-06-15-another-post.md").to_s
      assert_not_includes file_paths, Rails.root.join("app/content/posts/2023-05-15-sample-post.md").to_s
    end
  end

  test "falls back to the default locale directory when a locale directory is missing" do
    I18n.with_locale(:nl) do
      file_paths = @authors.send(:load_resources).map { it.file_path.to_s }

      assert file_paths.none? { it.include?("/authors/nl/") }
      assert_includes file_paths, Rails.root.join("app/content/authors/not-rails-designer.md").to_s
    end
  end

  test "test includes untranslated default pages with translated ones winning" do
    I18n.with_locale(:nl) do
      file_paths = @pages.send(:load_resources).map(&:file_path).map(&:to_s)
      stems = @pages.send(:load_resources).map(&:translation_key)

      assert_includes stems, "root"
      assert_includes file_paths, Rails.root.join("app/content/pages/pricing.erb").to_s
      assert_not_includes file_paths, Rails.root.join("app/content/pages/about.md").to_s
      assert_includes file_paths, Rails.root.join("app/content/pages/nl/about.md").to_s
      assert_equal stems.size, stems.uniq.size
    end
  end

  test "resolves localized files nested in subdirectories" do
    FileUtils.mkdir_p(Rails.root.join("app/content/posts/nl/guides"))
    File.write(Rails.root.join("app/content/posts/nl/guides/handleiding.md"), "---\ntitle: Handleiding\n---\n")

    I18n.with_locale(:nl) do
      file_paths = @posts.send(:load_resources).map(&:file_path).map(&:to_s)

      assert_includes file_paths, Rails.root.join("app/content/posts/nl/guides/handleiding.md").to_s
    end
  ensure
    FileUtils.rm_r(Rails.root.join("app/content/posts/nl/guides"))
  end

  test "find_by_file_name resolves the localized file first" do
    I18n.with_locale(:nl) do
      resource = @posts.find_by_file_name("2023-05-15-sample-post", Content::Post)

      assert_includes resource.file_path.to_s, "/posts/nl/"
    end

    I18n.with_locale(:en) do
      resource = @posts.find_by_file_name("2023-05-15-sample-post", Content::Post)

      assert_includes resource.file_path.to_s, "/posts/2023-05-15-sample-post.md"
    end
  end
end

class Perron::DataSource::LocaleResolutionTest < ActiveSupport::TestCase
  teardown do
    I18n.locale = I18n.default_locale
  end

  test "path_for prefers the suffixed locale file" do
    I18n.with_locale(:nl) do
      assert_includes Perron::DataSource.path_for("users"), "users.nl.yml"
    end

    I18n.with_locale(:en) do
      assert_includes Perron::DataSource.path_for("users"), "users.yml"
    end
  end

  test "loads records from the localized data file" do
    I18n.with_locale(:nl) do
      assert_equal "Camerijn", Content::Data::Users.first.name
      assert_equal "beheerder", Content::Data::Users.first.role
    end

    I18n.with_locale(:en) do
      assert_equal "Cam", Content::Data::Users.first.name
    end
  end

  test "falls back to the default locale data file when the localized one is missing" do
    I18n.with_locale(:nl) do
      assert_includes Perron::DataSource.path_for("editors"), "editors.yml"
    end
  end
end

class Perron::LocalizedRequestsTest < ActionDispatch::IntegrationTest
  teardown { I18n.locale = I18n.default_locale }

  test "unprefixed paths serve the default locale" do
    get "/blog/sample-post"

    assert_response :success
    assert_match "Labore qui mollit", response.body
  end

  test "locale-prefixed paths serve translated content" do
    get "/nl/blog/sample-post"

    assert_response :success
    assert_match "Nederlandse inhoud van het voorbeeldbericht", response.body
    assert_match "Kalm aan en netjes", response.body
  end

  test "locale-prefixed index renders localized and untranslated resources" do
    get "/nl/blog"

    assert_response :success
    assert_match "sample-post", response.body
    assert_match "another-post", response.body
  end

  test "unknown locale prefixes do not match routes" do
    get "/fr/blog/sample-post"

    assert_response :not_found
  end

  test "untranslated pages serve default content under the locale prefix" do
    get "/nl/pricing"

    assert_response :success
    assert_match "Pricing content", response.body
  end

  test "links rendered on a locale page stay within the locale" do
    get "/nl/blog"

    assert_response :success
    assert_match %r{/nl/blog/sample-post}, response.body
  end
end

class Perron::AutoLocalizedRootTest < ActionDispatch::IntegrationTest
  teardown { I18n.locale = I18n.default_locale }

  test "the default root route still resolves" do
    get "/"

    assert_response :success
    assert_match "Homepage", response.body
  end

  test "the localized root resolves without a manual route" do
    get "/nl"

    assert_response :success
    assert_match "Nederlandse inhoud van de homepagina", response.body
  end

  test "the localized root serves the nl locale" do
    get "/nl"

    assert_response :success
    assert_match "Kalm aan en netjes", response.body
    assert_equal :nl, I18n.locale
  end
end

class Perron::LocalizedRootRouteTest < ActiveSupport::TestCase
  test "the engine registers a named localized root route" do
    assert Rails.application.routes.named_routes.key?(:localized_root)
  end

  test "the localized root path helper builds per-locale paths" do
    assert_equal "/nl", Perron::Site::Builder::RouteResources
      .module_eval { Rails.application.routes.url_helpers.localized_root_path(locale: :nl) }
  end
end

class Perron::Site::Builder::Page::LocalizedRootTest < ActiveSupport::TestCase
  setup do
    FileUtils.rm_rf(Rails.root.join("output"))
    FileUtils.mkdir_p(Rails.root.join("output"))
  end

  teardown do
    FileUtils.rm_rf(Rails.root.join("output"))
    I18n.locale = I18n.default_locale
  end

  test "builds the localized root page" do
    capture_io { Perron::Site::Builder::Page.new("/nl/").render }

    file = Rails.root.join("output/nl/index.html")

    assert file.exist?, "expected output/nl/index.html to be built"
    assert_match "Nederlandse inhoud van de homepagina", file.read
  end

  test "builds the default root page" do
    capture_io { Perron::Site::Builder::Page.new("/").render }

    file = Rails.root.join("output/index.html")

    assert file.exist?, "expected output/index.html to be built"
    assert_match "Homepage", file.read
  end
end

class Perron::Site::Builder::Page::LocaleTest < ActiveSupport::TestCase
  setup do
    FileUtils.rm_rf(Rails.root.join("output"))
    FileUtils.mkdir_p(Rails.root.join("output"))
  end

  teardown do
    FileUtils.rm_rf(Rails.root.join("output"))
    I18n.locale = I18n.default_locale
  end

  test "builds unprefixed paths into the default locale output" do
    capture_io { Perron::Site::Builder::Page.new("/blog/sample-post/").render }

    file = output_pages.join("output/blog/sample-post/index.html")

    assert file.exist?
    assert_match "Labore qui mollit", file.read
  end

  test "builds locale-prefixed paths into the locale output" do
    capture_io { Perron::Site::Builder::Page.new("/nl/blog/sample-post/").render }

    file = output_pages.join("output/nl/blog/sample-post/index.html")

    assert file.exist?
    assert_match "Nederlandse inhoud van het voorbeeldbericht", file.read
  end

  test "builds the locale index" do
    capture_io { Perron::Site::Builder::Page.new("/nl/blog/").render }

    file = output_pages.join("output/nl/blog/index.html")

    assert file.exist?
    assert_match %r{/nl/blog/sample-post}, file.read
  end

  private

  def output_pages = Pathname.new(Rails.root.to_s)
end

class Perron::Site::Builder::Sitemap::LocaleTest < ActiveSupport::TestCase
  setup do
    @output_path = Dir.mktmpdir
    Perron.configuration.sitemap.enabled = true
  end

  teardown do
    FileUtils.remove_entry(@output_path)
    Perron.configuration.sitemap.enabled = false
  end

  test "includes locale alternates with per-locale locations" do
    capture_io { Perron::Site::Builder::Sitemap.new(Pathname.new(@output_path)).generate }

    xml = File.read("#{@output_path}/sitemap.xml")

    assert_match(/hreflang="en"/, xml)
    assert_match(/hreflang="nl"/, xml)
    assert_match(/hreflang="x-default"/, xml)
    assert_match(/<loc>http:\/\/localhost:3000\/blog\/sample-post\/<\/loc>/, xml)
    assert_match(/hreflang="nl" href="http:\/\/localhost:3000\/nl\/blog\/sample-post\/"/, xml)
  end

  test "builds clean locations for the root page per locale" do
    capture_io { Perron::Site::Builder::Sitemap.new(Pathname.new(@output_path)).generate }

    xml = File.read("#{@output_path}/sitemap.xml")

    assert_match(/<loc>http:\/\/localhost:3000\/<\/loc>/, xml)
    assert_match(/<loc>http:\/\/localhost:3000\/nl\/<\/loc>/, xml)
    assert_no_match(/%2F/, xml)
    assert_no_match(/\?locale=/, xml)
  end

  test "emits a url element per locale with identical alternates" do
    capture_io { Perron::Site::Builder::Sitemap.new(Pathname.new(@output_path)).generate }

    xml = File.read("#{@output_path}/sitemap.xml")

    assert_equal 1, xml.scan(%r{<loc>http://localhost:3000/blog/sample-post/</loc>}).size
    assert_equal 1, xml.scan(%r{<loc>http://localhost:3000/nl/blog/sample-post/</loc>}).size
    assert_equal 2, xml.scan(%r{hreflang="en" href="http://localhost:3000/blog/sample-post/"}m).size
    assert_equal 2, xml.scan(%r{hreflang="nl" href="http://localhost:3000/nl/blog/sample-post/"}m).size
    assert_equal 2, xml.scan(%r{hreflang="x-default" href="http://localhost:3000/blog/sample-post/"}m).size
  end

  test "root alternates group both locales in each url element" do
    capture_io { Perron::Site::Builder::Sitemap.new(Pathname.new(@output_path)).generate }

    xml = File.read("#{@output_path}/sitemap.xml")

    assert_equal 1, xml.scan(%r{<loc>http://localhost:3000/</loc>}).size
    assert_equal 1, xml.scan(%r{<loc>http://localhost:3000/nl/</loc>}).size
    assert_equal 2, xml.scan(%r{hreflang="nl" href="http://localhost:3000/nl/"}m).size
    assert_equal 2, xml.scan(%r{hreflang="x-default" href="http://localhost:3000/"}m).size
  end
end

class Perron::Site::Builder::Feeds::LocaleTest < ActiveSupport::TestCase
  setup do
    @output_path = Dir.mktmpdir

    Content::Post.configure do |config|
      config.feeds.atom.enabled = true
      config.feeds.atom.path = "feeds/posts.atom"
    end
  end

  teardown do
    FileUtils.remove_entry(@output_path)

    Content::Post.configure do |config|
      config.feeds.atom.enabled = false
    end

    I18n.locale = I18n.default_locale
  end

  test "generates a feed per locale" do
    capture_io { Perron::Site::Builder::Feeds.new(Pathname.new(@output_path)).generate }

    assert File.exist?("#{@output_path}/feeds/posts.atom")
    assert File.exist?("#{@output_path}/nl/feeds/posts.atom")

    dutch_feed = File.read("#{@output_path}/nl/feeds/posts.atom")

    assert_match "sample-post", dutch_feed
  end

  test "atom self and id URLs point at the localized feed" do
    atom = Perron::Site::Builder::Feeds::Atom.new(collection: Perron::Site.collection("posts"))

    I18n.with_locale(:nl) do
      assert_match %r{/nl/feeds/posts\.atom}, atom.send(:current_feed_url).to_s
    end
  end
end

class Perron::Collection::LocalizationDetectionTest < ActiveSupport::TestCase
  test "a collection is localized when it contains an available-locale subdirectory" do
    assert Perron::Site.find_collection("posts").localized?
    assert Perron::Site.find_collection("pages").localized?
  end

  test "a collection is not localized when it has no locale subdirectory" do
    assert_not Perron::Site.find_collection("features").localized?
  end
end

class Perron::Resource::LocaleTest < ActiveSupport::TestCase
  test "returns the locale of the file's directory" do
    assert_equal :nl, Content::Post.new("test/dummy/app/content/posts/nl/2023-05-15-sample-post.md").locale
  end

  test "returns nil for files of the base directory" do
    assert_nil Content::Post.new("test/dummy/app/content/posts/2023-05-15-sample-post.md").locale
  end
end

class Perron::Resource::TranslationKeyTest < ActiveSupport::TestCase
  teardown { FileUtils.rm_f(Rails.root.join("app/content/posts/2024-review.md")) }

  test "strips genuine date prefixes but keeps numeric-looking slugs" do
    FileUtils.touch(Rails.root.join("app/content/posts/2024-review.md"))

    assert_equal "sample-post", Content::Post.new("test/dummy/app/content/posts/2023-05-15-sample-post.md").translation_key
    assert_equal "2024-review", Content::Post.new("test/dummy/app/content/posts/2024-review.md").translation_key
  end

  test "pairs resources across locales by filename stem, while the slug may differ" do
    default = Content::Page.find!("about")
    localized = I18n.with_locale(:nl) { Perron::Site.find_collection("pages").find!("over-ons") }

    assert_equal default.translation_key, localized.translation_key
    assert_equal "about", default.slug
    assert_equal "over-ons", localized.slug
  end
end

class Perron::Site::Builder::Feeds::LocaleGatingTest < ActiveSupport::TestCase
  test "per-locale feeds only for collections with a locale subdirectory" do
    builder = Perron::Site::Builder::Feeds.new(Pathname.new(Dir.tmpdir))

    assert_equal [:en, :nl], builder.send(:collection_locales, Perron::Site.find_collection("posts"))
    assert_equal [:en], builder.send(:collection_locales, Perron::Site.find_collection("features"))
  end
end

class Perron::Metatags::AlternatesTest < ActiveSupport::TestCase
  test "renders hreflang alternates with x-default for a localized resource" do
    resource = Content::Post.new("test/dummy/app/content/posts/2023-05-15-sample-post.md")
    html = Perron::Metatags.new(resource.metadata).render

    assert_match(/rel="alternate" hreflang="en" href="http:\/\/localhost:3000\/blog\/sample-post\/"/, html)
    assert_match(/rel="alternate" hreflang="nl" href="http:\/\/localhost:3000\/nl\/blog\/sample-post\/"/, html)
    assert_match(/rel="alternate" hreflang="x-default"/, html)
  end

  test "renders clean alternates for the root page" do
    resource = I18n.with_locale(:nl) { Content::Page.root }
    html = Perron::Metatags.new(resource.metadata).render

    assert_match(/hreflang="en" href="http:\/\/localhost:3000\/"/, html)
    assert_match(/hreflang="nl" href="http:\/\/localhost:3000\/nl\/"/, html)
    assert_no_match(/%2F/, html)
  end

  test "includes untranslated pages as valid locale alternates" do
    resource = Content::Page.find!("pricing")
    urls = resource.metadata[:alternate_urls]

    assert urls.key?("en")
    assert urls.key?("nl")
    assert urls.key?("x-default")
  end

  test "canonicals fallback pages to the default-locale URL" do
    I18n.with_locale(:nl) do
      resource = Content::Page.find!("pricing")

      assert_match(%r{rel="canonical" href="http://localhost:3000/pricing/"}, Perron::Metatags.new(resource.metadata).render)
    end
  end

  test "pairs alternates by translation key, honoring translated slugs" do
    resource = Content::Page.find!("about")
    html = Perron::Metatags.new(resource.metadata).render

    assert_match(/hreflang="en" href="http:\/\/localhost:3000\/about\/"/, html)
    assert_match(/hreflang="nl" href="http:\/\/localhost:3000\/nl\/over-ons\/"/, html)
  end

  test "renders no alternates for non-localized collections" do
    resource = Content::Feature.new("test/dummy/app/content/features/beta-feature.md")

    assert_nil resource.metadata[:alternate_urls]
  end
end
