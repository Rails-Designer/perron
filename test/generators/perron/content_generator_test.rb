require "test_helper"
require "generators/rails/content/content_generator"

class ContentGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::ContentGenerator

  destination File.expand_path("../../dummy/tmp/generators", __dir__)

  setup :prepare_destination
  setup :create_routes_file

  test "no arguments generates index and show scaffold" do
    run_generator %w[post]

    assert_file "app/models/content/post.rb", /class Content::Post/
    assert_file "app/controllers/content/posts_controller.rb", /class Content::PostsController/

    assert_file "app/views/content/posts/index.html.erb"
    assert_file "app/views/content/posts/show.html.erb"

    assert_file "config/routes.rb", /resources :posts, module: :content, only: %w\[index show\]/
  end

  test "show argument generates only show action" do
    run_generator %w[post show]

    assert_file "app/models/content/post.rb", /class Content::Post/
    assert_file "app/controllers/content/posts_controller.rb", /class Content::PostsController/

    assert_file "app/views/content/posts/show.html.erb"

    assert_no_file "app/views/content/posts/index.html.erb"
  end

  test "--new flag creates content file" do
    run_generator %w[post --new]

    assert_file "app/content/posts/untitled.md", /---\n---\n/

    assert_no_file "app/models/content/post.rb"
    assert_no_file "app/controllers/content/posts_controller.rb"
  end

  test "--new with title creates named content file" do
    FileUtils.mkdir_p(File.join(destination_root, "app", "content", "posts"))
    File.write(File.join(destination_root, "app", "content", "posts", "template.md.tt"), "---\ntitle: <%= @title %>\n---\n")

    run_generator ["post", "--new=First Post"]

    assert_file "app/content/posts/first-post.md", /---\ntitle: First Post\n---\n/

    assert_no_file "app/models/content/post.rb"
    assert_no_file "app/controllers/content/posts_controller.rb"
  end

  test "pages generates root action and route by default" do
    run_generator %w[page]

    assert_file "app/models/content/page.rb", /class Content::Page/
    assert_file "app/controllers/content/pages_controller.rb" do |content|
      assert_match /class Content::PagesController/, content
      assert_match /def root/, content
      assert_match /@resource = Content::Page\.root/, content
      assert_match /render :show/, content
    end

    assert_file "app/content/pages/root.erb", /Find me in `app\/content\/pages\/root\.erb`/
    assert_file "config/routes.rb", /root to: "content\/pages#root"/
  end

  test "pages with --no-include-root skips root generation" do
    run_generator %w[page --no-include-root]

    assert_file "app/controllers/content/pages_controller.rb" do |content|
      assert_no_match /def root/, content
    end

    assert_no_file "app/content/pages/root.erb"
    assert_file "config/routes.rb" do |content|
      assert_no_match /root to:/, content
    end
  end

  test "non-pages with --include-root generates root" do
    run_generator %w[post --include-root]

    assert_file "app/controllers/content/posts_controller.rb" do |content|
      assert_match /def root/, content
    end

    assert_file "app/content/posts/root.erb"
    assert_file "config/routes.rb", /root to: "content\/posts#root"/
  end

  test "skips root route if one already exists" do
    File.write(File.join(destination_root, "config", "routes.rb"),
      "Rails.application.routes.draw do\n  root to: \"home#index\"\nend\n")

    run_generator %w[page]

    assert_file "config/routes.rb" do |content|
      assert_match /root to: "home#index"/, content
      assert_no_match /root to: "content\/pages#root"/, content
    end
  end

  test "--data flag creates data source files with default yml extension" do
    run_generator %w[product --data countries products]

    assert_file "app/content/products/countries.yml"
    assert_file "app/content/products/products.yml"

    assert_file "app/models/content/product.rb", /sources :countries, :products/
    assert_file "app/models/content/product.rb", /def self\.source_template\(sources\)/
  end

  test "--data flag creates data source files with custom extensions" do
    run_generator %w[product --data countries.json products.yml]

    assert_file "app/content/products/countries.json"
    assert_file "app/content/products/products.yml"

    assert_file "app/models/content/product.rb", /sources :countries, :products/
  end

  test "--data flag with mixed extensions" do
    run_generator %w[product --data countries.json products]

    assert_file "app/content/products/countries.json"
    assert_file "app/content/products/products.yml"

    assert_file "app/models/content/product.rb", /sources :countries, :products/
  end

  private

  def create_routes_file
    routes_path = File.join(destination_root, "config", "routes.rb")

    FileUtils.mkdir_p(File.dirname(routes_path))
    File.write(routes_path, "Rails.application.routes.draw do\nend\n")
  end
end
