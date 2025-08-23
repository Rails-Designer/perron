require "test_helper"

class Perron::Resource::RendererTest < ActiveSupport::TestCase
  setup do
    @resource_path = "test/dummy/app/content/pages/about.md"
    @resource = Perron::Resource.new(@resource_path)
  end

  test "renders basic ERB content" do
    content = "Math works: <%= 5 * 5 %>."
    rendered = Perron::Resource::Renderer.erb(content)

    assert_equal "Math works: 25.", rendered.strip
  end

  test "renders ERB with a resource object in assigns" do
    content = "<h1><%= @resource.metadata.title %></h1>"
    assigns = { resource: @resource }
    rendered = Perron::Resource::Renderer.erb(content, assigns)

    assert_equal "<h1>About</h1>", rendered.strip
  end

  test "handles content with no ERB tags gracefully" do
    content = "<p>This is just static text.</p>"
    rendered = Perron::Resource::Renderer.erb(content)

    assert_equal "<p>This is just static text.</p>", rendered.strip
  end
end
