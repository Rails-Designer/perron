require "test_helper"
require "open3"

class CliTest < ActiveSupport::TestCase
  EXE_PATH = File.expand_path("../../exe/perron", __dir__)

  test "shows help without args" do
    stdout, stderr, status = Open3.capture3("ruby", EXE_PATH)

    assert_match(/Usage: perron <command>/, stdout + stderr)
    assert_match(/perron new APPNAME/, stdout + stderr)
    assert_match(/perron generate/, stdout + stderr)
    assert_match(/perron build/, stdout + stderr)
    assert_match(/perron clobber/, stdout + stderr)
    assert_match(/perron deploy/, stdout + stderr)
  end

  test "shows help with --help" do
    stdout, stderr, status = Open3.capture3("ruby", EXE_PATH, "--help")

    assert_match(/Usage: perron <command>/, stdout + stderr)
  end

  test "shows help with -h" do
    stdout, stderr, status = Open3.capture3("ruby", EXE_PATH, "-h")

    assert_match(/Usage: perron <command>/, stdout + stderr)
  end

  test "errors on unknown command" do
    stdout, stderr, status = Open3.capture3("ruby", EXE_PATH, "unknown")

    assert_equal 1, status.exitstatus
    assert_match(/Unknown command: unknown/, stdout + stderr)
  end

  test "errors on new without app name" do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        stdout, stderr, status = Open3.capture3("ruby", EXE_PATH, "new")

        assert_equal 1, status.exitstatus
        assert_match(/Error: app name required/, stdout + stderr)
      end
    end
  end

  test "errors when bin/rails not found" do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        stdout, stderr, status = Open3.capture3("ruby", EXE_PATH, "build")

        assert_equal 1, status.exitstatus
        assert_match(/bin\/rails not found/, stdout + stderr)
      end
    end
  end
end