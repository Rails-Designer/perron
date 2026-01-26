# frozen_string_literal: true

require "test_helper"

class Perron::SearchesControllerTest < ActionDispatch::IntegrationTest
  test "show returns json with search index" do
    get search_path

    assert_response :success

    json = JSON.parse(response.body)

    assert json.size > 0
    assert_includes json.first.keys, "slug"
    assert_includes json.first.keys, "body"
  end

  test "show forces json format" do
    get search_path, headers: { "Accept" => "text/html" }

    assert_equal "application/json", response.media_type
  end
end
