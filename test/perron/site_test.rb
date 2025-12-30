require "test_helper"

class Perron::SiteTest < ActiveSupport::TestCase
  teardown { Perron::Site.instance_variable_set(:@collections, nil) }

  test "collection(name) returns a Perron::Site::Collection instance" do
    assert_instance_of Perron::Collection, Perron::Site.collection("posts")
  end

  test "collections returns all collections as Perron::Site::Collection instances" do
    assert Perron::Site.collections.all? { it.is_a?(Perron::Collection) }
  end
end
