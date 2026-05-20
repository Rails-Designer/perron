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
    assert_file "app/controllers/content/posts_controller.rb", /@resource = Content::Post.find!\(params\[:id\]\)/
    assert_file "app/controllers/content/posts_controller.rb" do |content|
      refute_match(/\n\n\n/, content, "Controller should not have triple newlines")
    end

    assert_file "app/views/content/posts/index.html.erb"
    assert_file "app/views/content/posts/show.html.erb"

    assert_file "config/routes.rb", /resources :posts, module: :content, only: %w\[index show\]/
  end

  test "show argument generates only show action" do
    run_generator %w[post show]

    assert_file "app/models/content/post.rb", /class Content::Post/
    assert_file "app/controllers/content/posts_controller.rb", /class Content::PostsController/
    assert_file "app/controllers/content/posts_controller.rb" do |content|
      refute_match(/\n\n\n/, content, "Controller should not have triple newlines")
    end

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
    File.write(File.join(destination_root, "app", "content", "posts", "title.md.tt"), "---\ntitle: <%= @title %>\n---\n")

    run_generator ["post", "--new=First Post"]

    assert_file "app/content/posts/first-post.md", /---\ntitle: First Post\n---\n/

    assert_no_file "app/models/content/post.rb"
    assert_no_file "app/controllers/content/posts_controller.rb"
  end

  test "--new with strftime template creates timestamped file" do
    FileUtils.mkdir_p(File.join(destination_root, "app", "content", "posts"))
    File.write(File.join(destination_root, "app", "content", "posts", "%s-title.md.tt"), "---\ntitle: <%= @title %>\n---\n")

    freeze_time do
      run_generator ["post", "--new=My Post"]

      timestamp = Time.current.strftime("%s")
      assert_file "app/content/posts/#{timestamp}-my-post.md", /---\ntitle: My Post\n---\n/
    end
  end

  test "--new with day title creates day-prefixed file" do
    FileUtils.mkdir_p(File.join(destination_root, "app", "content", "posts"))
    File.write(File.join(destination_root, "app", "content", "posts", "%d-title.md.tt"), "---\ntitle: <%= @title %>\n---\n")

    freeze_time do
      run_generator ["post", "--new=Daily Note"]

      day = Time.current.strftime("%d")
      assert_file "app/content/posts/#{day}-daily-note.md", /---\ntitle: Daily Note\n---\n/
    end
  end

  test "--new with timestamp-only template creates file without title" do
    FileUtils.mkdir_p(File.join(destination_root, "app", "content", "posts"))
    File.write(File.join(destination_root, "app", "content", "posts", "%s.md.tt"), "---\ntitle: <%= @title %>\n---\n")

    freeze_time do
      run_generator ["post", "--new=My Post"]

      timestamp = Time.current.strftime("%s")
      assert_file "app/content/posts/#{timestamp}.md", /---\ntitle: My Post\n---\n/
    end
  end

  test "--new with title word gets title replacement" do
    FileUtils.mkdir_p(File.join(destination_root, "app", "content", "posts"))
    File.write(File.join(destination_root, "app", "content", "posts", "%s-title.md.tt"), "---\ntitle: <%= @title %>\n---\n")

    freeze_time do
      run_generator ["post", "--new=My Post"]

      timestamp = Time.current.strftime("%s")
      assert_file "app/content/posts/#{timestamp}-my-post.md", /---\ntitle: My Post\n---\n/
    end
  end

  test "--new with no title word and no strftime uses filename as-is" do
    FileUtils.mkdir_p(File.join(destination_root, "app", "content", "posts"))
    File.write(File.join(destination_root, "app", "content", "posts", "draft.md.tt"), "---\ntitle: <%= @title %>\n---\n")

    run_generator ["post", "--new=My Post"]

    assert_file "app/content/posts/draft.md", /---\ntitle: My Post\n---\n/
  end

  test "pages generates root action and route by default" do
    run_generator %w[page]

    assert_file "config/routes.rb", /root to: "content\/pages#root"/
    assert_file "app/models/content/page.rb", /class Content::Page/
    assert_file "app/controllers/content/pages_controller.rb" do |content|
      expected = <<~CONTROLLER
        class Content::PagesController < ApplicationController
          def root
            @resource = Content::Page.root

            render :show
          end

          def index
            @resources = Content::Page.all
          end

          def show
            @resource = Content::Page.find!(params[:id])
          end
        end
      CONTROLLER

      assert_equal expected, content, "Controller should have properly formatted root action"
    end

    assert_file "app/content/pages/root.erb", /Find me in `app\/content\/pages\/root\.erb`/
  end

  test "pages with show action only generates root and show" do
    run_generator %w[page show]

    assert_file "app/controllers/content/pages_controller.rb" do |content|
      expected = <<~CONTROLLER
        class Content::PagesController < ApplicationController
          def root
            @resource = Content::Page.root

            render :show
          end

          def show
            @resource = Content::Page.find!(params[:id])
          end
        end
      CONTROLLER

      assert_equal expected, content, "Controller should have properly formatted root and show actions"
    end
  end

  test "destroy removes files without crashing" do
    run_generator %w[page]
    run_generator %w[page], behavior: :revoke

    assert_no_file "app/models/content/page.rb"
    assert_no_file "app/controllers/content/pages_controller.rb"
    assert_no_file "app/views/content/pages"
    assert_no_file "app/content/pages/root.erb"
  end

  test "pages with --no-include-root skips root generation" do
    run_generator %w[page --no-include-root]

    assert_file "app/controllers/content/pages_controller.rb" do |content|
      assert_no_match (/def root/), content
    end

    assert_no_file "app/content/pages/root.erb"
    assert_file "config/routes.rb" do |content|
      assert_no_match (/root to:/), content
    end
  end

  test "non-pages with --include-root generates root" do
    run_generator %w[post --include-root]

    assert_file "app/controllers/content/posts_controller.rb" do |content|
      expected = <<~CONTROLLER
        class Content::PostsController < ApplicationController
          def root
            @resource = Content::Post.root

            render :show
          end

          def index
            @resources = Content::Post.all
          end

          def show
            @resource = Content::Post.find!(params[:id])
          end
        end
      CONTROLLER

      assert_equal expected, content, "Controller should have properly formatted root action"
    end

    assert_file "app/content/posts/root.erb"
    assert_file "config/routes.rb", (/root to: "content\/posts#root"/)
  end

  test "skips root route if one already exists" do
    File.write(File.join(destination_root, "config", "routes.rb"),
      "Rails.application.routes.draw do\n  root to: \"home#index\"\nend\n")

    run_generator %w[page]

    assert_file "config/routes.rb" do |content|
      assert_match (/root to: "home#index"/), content
      assert_no_match (/root to: "content\/pages#root"/), content
    end
  end

  test "--data flag creates data source files with default yml extension" do
    run_generator %w[product --data countries products]

    assert_file "app/content/data/countries.yml"
    assert_file "app/content/data/products.yml"

    assert_file "app/models/content/product.rb", /sources :countries, :products/
    assert_file "app/models/content/product.rb", /def self\.source_template\(source\)/
  end

  test "--data flag creates data source files with custom extensions" do
    run_generator %w[product --data countries.json products.yml]

    assert_file "app/content/data/countries.json"
    assert_file "app/content/data/products.yml"

    assert_file "app/models/content/product.rb", /sources :countries, :products/
  end

  test "--data flag with mixed extensions" do
    run_generator %w[product --data countries.json products]

    assert_file "app/content/data/countries.json"
    assert_file "app/content/data/products.yml"

    assert_file "app/models/content/product.rb", /sources :countries, :products/
  end

  test "--inline flag skips show view and renders inline" do
    run_generator %w[post --inline]

    assert_file "app/models/content/post.rb", /class Content::Post/
    assert_file "app/controllers/content/posts_controller.rb" do |content|
      assert_match(/render @resource\.inline/, content)
    end

    assert_file "app/views/content/posts/index.html.erb"
    assert_no_file "app/views/content/posts/show.html.erb"
  end

  test "--inline flag with only show action" do
    run_generator %w[post show --inline]

    assert_file "app/controllers/content/posts_controller.rb" do |content|
      assert_match(/render @resource\.inline/, content)
    end

    assert_no_file "app/views/content/posts/index.html.erb"
    assert_no_file "app/views/content/posts/show.html.erb"
  end

  private

  def create_routes_file
    routes_path = File.join(destination_root, "config", "routes.rb")

    FileUtils.mkdir_p(File.dirname(routes_path))
    File.write(routes_path, "Rails.application.routes.draw do\nend\n")
  end
end
