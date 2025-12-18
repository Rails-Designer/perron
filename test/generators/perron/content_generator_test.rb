require "test_helper"
require "generators/rails/content/content_generator"

class ContentGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::ContentGenerator

  destination File.expand_path("../dummy/tmp/generators", __dir__)

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

  private

  def create_routes_file
    routes_path = File.join(destination_root, "config", "routes.rb")

    FileUtils.mkdir_p(File.dirname(routes_path))
    File.write(routes_path, "Rails.application.routes.draw do\nend\n")
  end
end
