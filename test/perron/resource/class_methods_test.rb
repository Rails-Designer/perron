require "test_helper"

class Perron::Resource::ClassMethodsTest < ActiveSupport::TestCase
  test ".all returns collection of resources" do
    posts = Content::Post.all

    assert_equal 3, posts.size
    assert_instance_of Content::Post, posts.first
  end

  test ".count returns the number of resources" do
    assert_equal 3, Content::Post.count
    assert_equal 4, Content::Page.count
  end

  test ".first returns the first resource" do
    post = Content::Post.first

    assert_instance_of Content::Post, post
  end

  test ".first(n) returns the first n resources" do
    posts = Content::Post.first(2)

    assert_equal 2, posts.size
    assert_instance_of Content::Post, posts.first
  end

  test ".second returns the second resource" do
    post = Content::Post.second

    assert_instance_of Content::Post, post
    assert_equal "another-post", post.slug
  end

  test ".third returns the third resource" do
    post = Content::Post.third

    assert_instance_of Content::Post, post
    assert_equal "inline-erb-post", post.slug
  end

  test ".fourth returns nil when not enough resources" do
    assert_nil Content::Post.fourth
  end

  test ".fifth returns nil when not enough resources" do
    assert_nil Content::Post.fifth
  end

  test ".forty_two returns nil when not enough resources" do
    assert_nil Content::Post.forty_two
  end

  test ".last returns the last resource" do
    post = Content::Post.last

    assert_instance_of Content::Post, post
    assert_equal "inline-erb-post", post.slug
  end

  test ".take returns the first n resources" do
    posts = Content::Post.take(2)

    assert_equal 2, posts.size
    assert_instance_of Content::Post, posts.first
  end

  test ".take returns all resources when n is larger than collection" do
    posts = Content::Post.take(10)

    assert_equal 3, posts.size
  end

  test ".find returns resource by slug" do
    post = Content::Post.find("sample-post")

    assert_instance_of Content::Post, post
    assert_equal "sample-post", post.slug
  end

  test ".find raises error for non-existent slug" do
    assert_raises Perron::Errors::ResourceNotFoundError do
      Content::Post.find("non-existent-slug")
    end
  end

  test ".root returns root page for pages collection" do
    root = Content::Page.root

    assert_instance_of Content::Page, root
  end

  test ".root returns false for non-page collections" do
    root = Content::Post.root

    assert_equal false, root
  end

  test ".model_name returns ActiveModel::Name" do
    model_name = Content::Post.model_name

    assert_instance_of ActiveModel::Name, model_name
    assert_equal "Post", model_name.name
  end

  test ".collection returns Collection instance" do
    collection = Content::Post.collection

    assert_instance_of Perron::Collection, collection
  end
end
