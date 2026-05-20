require "test_helper"

class Perron::Site::ValidateTest < ActiveSupport::TestCase
  def test_prints_failure_for_yaml_syntax_error
    content_dir = Rails.root.join("app/content/pages")
    syntax_error_file = content_dir.join("syntax-error.md")

    File.write(syntax_error_file, <<~CONTENT)
      ---
      title: Syntax Error
      invalid: yaml: here
      ---
      Content
    CONTENT

    validator = Perron::Site::Validate.new(collections: [Content::Page.collection])

    output = capture_io { validator.validate }

    assert_match(/Invalid YAML/, output.join)
    assert_match(/line 2/, output.join)
  ensure
    File.delete(syntax_error_file) if File.exist?(syntax_error_file)
  end

  def test_prints_failure_for_validation_errors
    validator = Perron::Site::Validate.new(collections: [Content::Page.collection])

    output = capture_io { validator.validate }

    assert_match(/failures/, output.join)
  end
end
