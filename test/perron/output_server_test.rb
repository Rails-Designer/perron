require "test_helper"
require "tmpdir"
require "pathname"

class Perron::OutputServerTest < ActiveSupport::TestCase
  setup do
    @root = Dir.mktmpdir
    @app = ->(_env) { [200, {"Content-Type" => "text/html"}, ["from rails"]] }
  end

  teardown do
    FileUtils.remove_entry(@root)
  end

  test "falls through to Rails for missing static HTML when not strict" do
    FileUtils.mkdir_p(File.join(@root, "public"))

    status, _headers, body = call_server(output: "public", strict: false, path: "/some-dynamic-page")

    assert_equal 200, status
    assert_equal ["from rails"], body
  end

  test "serves built static HTML when present" do
    write_static("public", "/post", "<html><head><title>Hello</title></head></html>")

    status, _headers, body = call_server(output: "public", strict: false, path: "/post")

    assert_equal 200, status
    assert_includes body.first, "[PREVIEW] Hello"
  end

  test "returns 404 for missing static HTML when strict" do
    FileUtils.mkdir_p(File.join(@root, "public"))

    status, headers, body = call_server(output: "public", strict: true, path: "/some-dynamic-page")

    assert_equal 404, status
    assert_equal "text/plain", headers["Content-Type"]
    assert_equal ["Not Found"], body
  end

  test "is disabled when the output directory does not exist" do
    status, _headers, body = call_server(output: "output", strict: true, path: "/some-dynamic-page")

    assert_equal 200, status
    assert_equal ["from rails"], body
  end

  private

  def call_server(output:, path:, strict:)
    config = Struct.new(:output, :output_server_strict).new(output, strict)

    Rails.stub(:root, Pathname.new(@root)) do
      Perron.stub(:configuration, config) do
        Perron::OutputServer.new(@app).call(Rack::MockRequest.env_for(path))
      end
    end
  end

  def write_static(directory, path, contents)
    file_path = File.join(@root, directory, path, "index.html")
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, contents)
  end
end
