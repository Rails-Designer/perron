require "test_helper"

class Perron::Resource::ClassMethodsTest < ActiveSupport::TestCase
  test ".all returns collection of resources" do
    posts = Content::Post.all

    assert_equal 4, posts.size
    assert_instance_of Content::Post, posts.first
  end

  test ".count returns the number of resources" do
    assert_equal 4, Content::Post.count
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
    assert_nil Content::Post.fifth
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
    assert_equal "no-author", post.slug
  end

  test ".take returns the first n resources" do
    posts = Content::Post.take(2)

    assert_equal 2, posts.size
    assert_instance_of Content::Post, posts.first
  end

  test ".take returns all resources when n is larger than collection" do
    posts = Content::Post.take(10)

    assert_equal 4, posts.size
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

  test ".model_name returns ActiveModel::Name" do
    model_name = Content::Post.model_name

    assert_instance_of ActiveModel::Name, model_name
    assert_equal "Post", model_name.name
  end

  test ".collection returns Collection instance" do
    collection = Content::Post.collection

    assert_instance_of Perron::Collection, collection
  end

  test ".where filters resources by single condition" do
    posts = Content::Post.where(slug: "sample-post")

    assert_instance_of Perron::Relation, posts
    assert_equal 1, posts.size
    assert_equal "sample-post", posts.first.slug
  end

  test ".where filters resources with array of values" do
    posts = Content::Post.where(slug: ["sample-post", "another-post"])

    assert_equal 2, posts.size
  end

  test ".where returns empty relation when no matches" do
    posts = Content::Post.where(slug: "non-existent")

    assert_instance_of Perron::Relation, posts
    assert_equal 0, posts.size
  end

  test ".order sorts resources by attribute ascending" do
    posts = Content::Post.order(:slug)

    assert_instance_of Perron::Relation, posts
    assert_equal "another-post", posts.first.slug
  end

  test ".order sorts resources by attribute descending" do
    posts = Content::Post.order(:slug, :desc)

    assert_equal "sample-post", posts.first.slug
  end

  test ".limit returns limited number of resources" do
    posts = Content::Post.limit(2)

    assert_instance_of Perron::Relation, posts
    assert_equal 2, posts.size
  end

  test ".offset skips specified number of resources" do
    posts = Content::Post.offset(2)

    assert_instance_of Perron::Relation, posts
    assert_equal 2, posts.size
  end
end
