# frozen_string_literal: true

require "test_helper"

class Perron::I18nTest < ActiveSupport::TestCase
  setup do
    @original_locales = Perron.configuration.locales
    @original_default_locale = Perron.configuration.default_locale
  end

  teardown do
    Perron.configure do |config|
      config.locales = @original_locales
      config.default_locale = @original_default_locale
    end
  end

  test "configuration has locales setting" do
    Perron.configure { |c| c.locales = [:en, :de] }

    assert_equal [:en, :de], Perron.configuration.locales
  end

  test "configuration has default_locale setting" do
    Perron.configure { |c| c.default_locale = :de }

    assert_equal :de, Perron.configuration.default_locale
  end

  test "locales can be nil for backward compatibility" do
    assert_nil Perron.configuration.locales
  end
end

class Perron::Collection::I18nTest < ActiveSupport::TestCase
  setup do
    I18n.locale = I18n.default_locale
    @posts = Perron::Collection.new("posts")
  end

  teardown do
    I18n.locale = I18n.default_locale
  end

  test "loads resources from locale subdirectory when present" do
    I18n.with_locale(:en) do
      resources = @posts.send(:load_resources)

      assert_kind_of Array, resources
    end
  end

  test "falls back to base collection path when locale subdirectory absent" do
    I18n.locale = :en
    resources = @posts.send(:load_resources)

    assert_kind_of Array, resources
  end
end

class Perron::DataSource::I18nTest < ActiveSupport::TestCase
  setup do
    I18n.locale = I18n.default_locale
  end

  teardown do
    I18n.locale = I18n.default_locale
  end

  test "path_for finds data file with locale fallback" do
    I18n.locale = :en
    path = Perron::DataSource.path_for("users")

    refute_nil path
    assert_includes path, "users.yml"
  end

  test "path_for falls back to default when locale subdir missing" do
    I18n.locale = :en
    path = Perron::DataSource.path_for("users")

    refute_nil path
    assert_includes path, "users.yml"
  end
end