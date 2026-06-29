require "test_helper"
require "support/data_api_source"

class Perron::Resource::SourceableTest < ActiveSupport::TestCase
  setup do
    @output_dir = Rails.root.join("app/content/products")
  end

  teardown do
    [Rails.root.join("app/content/products"), Rails.root.join("app/content/comparisons"),
     Rails.root.join("app/content/md_products"), Rails.root.join("app/content/md_comparisons")].each do |dir|
      FileUtils.rm_rf(dir) if dir.exist?
    end
  end

  test ".sources sets source names and definitions" do
    assert_equal [:countries, :products], Content::Product.source_names

    assert_equal :id, Content::Product.source_definitions[:countries][:primary_key]
    assert_equal :code, Content::Product.source_definitions[:products][:primary_key]
  end

  test ".source_backed? returns true when sources defined" do
    assert Content::Product.source_backed?
  end

  test ".source_backed? returns false when no sources defined" do
    assert_equal [], Content::Page.source_names
    refute Content::Page.source_backed?
  end

  test ".generate_from_sources! creates files for all combinations" do
    Content::Product.generate_from_sources!

    assert_path_exists @output_dir.join("us-iphone-15.erb")
    assert_path_exists @output_dir.join("uk-iphone-15.erb")
    assert_path_exists @output_dir.join("us-ipad-pro.erb")
    assert_path_exists @output_dir.join("uk-ipad-pro.erb")
  end

  test ".generate_from_sources! writes correct frontmatter" do
    Content::Product.generate_from_sources!

    content = File.read(@output_dir.join("us-iphone-15.erb"))

    assert_match(/product_code: iphone-15/, content)
    assert_match(/country_id: us/, content)
    assert_match(/title: iPhone in United States/, content)
  end

  test "#sources loads source data from frontmatter" do
    FileUtils.mkdir_p(@output_dir)
    test_file = @output_dir.join("test.erb")

    File.write(test_file, <<~CONTENT)
      ---
      product_code: iphone-15
      country_id: us
      ---
    CONTENT

    resource = Content::Product.new(test_file.to_s)

    assert_equal "1", resource.sources.products.id
    assert_equal "iphone-15", resource.sources.products.code
    assert_equal "iPhone", resource.sources.products.name
    assert_equal "iphone", resource.sources.products.slug
    assert_equal "999", resource.sources.products.price
    assert_equal "us", resource.sources.countries.id
    assert_equal "United States", resource.sources.countries.name
    assert_equal "US", resource.sources.countries.code
  end

  test "#source_backed? returns true for source-backed resource instance" do
    FileUtils.mkdir_p(@output_dir)
    test_file = @output_dir.join("test.erb")
    File.write(test_file, "---\nproduct_code: iphone-15\n---")

    resource = Content::Product.new(test_file.to_s)

    assert resource.source_backed?
  end

  test ".sources with custom class uses class.all method" do
    test_class = Class.new(Perron::Resource) do
      sources products: { class: DataApiSource }

      def self.source_template(source)
        "test template"
      end
    end

    combinations = test_class.send(:derive)

    assert_equal 2, combinations.length
    assert_equal "product-1", combinations.first.first.id
    assert_equal "product-2", combinations.last.first.id
  end

  test ".sources with custom class and scope combines both" do
    test_class = Class.new(Perron::Resource) do
      sources products: {
        class: DataApiSource,
        scope: -> (products) { products.select(&:active) }
      }

      def self.source_template(source)
        "test template"
      end
    end

    combinations = test_class.send(:derive)

assert_equal 1, combinations.length
    assert_equal "product-1", combinations.first.first.id
  end

  test "raises DataParseError for CSV source with nil primary key" do
    test_class = Class.new(Perron::Resource) do
      sources :products_with_missing

      def self.source_template(source)
        "test template"
      end
    end

    error = assert_raises Perron::Errors::DataParseError do
      test_class.send(:derive)
    end

    assert_includes error.message, "Primary key"
    assert_includes error.message, "id"
  end

  test ".source with mode: :combinations parses correctly" do
    test_class = Class.new(Perron::Resource) do
      source comparisons: { primary_key: :code, mode: :combinations }

      def self.source_template(source)
        "test"
      end
    end

    assert_equal :code, test_class.source_definitions[:comparisons][:primary_key]
    assert_equal :combinations, test_class.source_definitions[:comparisons][:mode]
  end

  test "sources with mode option raises ArgumentError" do
    error = assert_raises ArgumentError do
      Class.new(Perron::Resource) do
        sources :countries, products: { primary_key: :code, mode: :combinations }

        def self.source_template(source)
          "test"
        end
      end
    end

    assert_includes error.message, "mode is only supported for single-source definitions"
  end

  test ".derive with mode: :combinations generates n*(n-1)/2 pairs" do
    test_class = Class.new(Perron::Resource) do
      source comparisons: { primary_key: :code, mode: :combinations }

      def self.source_template(source)
        "test"
      end
    end

    pairs = test_class.send(:derive).to_a

    assert_equal 3, pairs.length
    assert_equal ["a", "b"], pairs[0].map(&:code)
    assert_equal ["a", "c"], pairs[1].map(&:code)
    assert_equal ["b", "c"], pairs[2].map(&:code)
  end

  test ".derive with mode: :single returns one item per row" do
    test_class = Class.new(Perron::Resource) do
      source products: { primary_key: :id, mode: :single }

      def self.source_template(source)
        "test"
      end
    end

    items = test_class.send(:derive).to_a

    assert_equal 2, items.length
    assert_equal ["1"], items[0].map(&:id)
    assert_equal ["2"], items[1].map(&:id)
  end

  test ".derive with unknown mode raises ArgumentError" do
    test_class = Class.new(Perron::Resource) do
      source comparisons: { primary_key: :code, mode: :invalid }

      def self.source_template(source)
        "test"
      end
    end

    error = assert_raises ArgumentError do
      test_class.send(:derive)
    end

    assert_includes error.message, "Unknown mode"
  end

  test ".generate_from_sources! with mode: :combinations creates correct files" do
    @output_dir = Rails.root.join("app/content/comparisons")
    FileUtils.mkdir_p(@output_dir)

    Content::Comparison.generate_from_sources!

    assert_path_exists @output_dir.join("a-b.erb")
    assert_path_exists @output_dir.join("a-c.erb")
    assert_path_exists @output_dir.join("b-c.erb")
    refute_path_exists @output_dir.join("b-a.erb")
  end

  test ".generate_from_sources! with mode: :combinations writes correct frontmatter" do
    @output_dir = Rails.root.join("app/content/comparisons")
    FileUtils.mkdir_p(@output_dir)

    Content::Comparison.generate_from_sources!

    content = File.read(@output_dir.join("a-b.erb"))

    assert_match(/comparison_1_code: a/, content)
    assert_match(/comparison_2_code: b/, content)
  end

  test ".generate_from_sources! with mode: :combinations generates correct template content" do
    @output_dir = Rails.root.join("app/content/comparisons")
    FileUtils.mkdir_p(@output_dir)

    Content::Comparison.generate_from_sources!

    content = File.read(@output_dir.join("a-b.erb"))

    assert_match(/Tool A vs Tool B/, content)
    assert_match(/Price difference: \$-100/, content)
  end

  test ".source with mode: :combinations and :as option uses custom names" do
    test_class = Class.new(Perron::Resource) do
      source comparisons: { primary_key: :code, mode: :combinations, as: [:left, :right] }

      def self.source_template(source)
        "test"
      end
    end

    pairs = test_class.send(:derive).to_a

    source_name = test_class.source_names.first
    source_defs = test_class.source_definitions[source_name]
    names = source_defs[:as]&.map(&:to_sym) || (1..pairs.first.size).map { :"#{source_name}_#{it}" }
    data = pairs.first.each_with_index.to_h { |item, index| [names[index], item] }

    assert_includes data.keys, :left
    assert_includes data.keys, :right
    refute_includes data.keys, :comparisons_1
    refute_includes data.keys, :comparisons_2
  end

  test ".generate_from_sources! with extension: :md creates .md files" do
    test_class = Class.new(Perron::Resource) do
      source products: { primary_key: :id, extension: :md }

      def self.source_template(source)
        "test"
      end
    end

    Content.const_set(:MdProduct, test_class)

    test_class.generate_from_sources!

    assert_path_exists Rails.root.join("app/content/md_products/1.md")
    assert_path_exists Rails.root.join("app/content/md_products/2.md")
  ensure
    Content.send(:remove_const, :MdProduct) rescue nil
  end

  test ".generate_from_sources! with extension and mode: :combinations creates .md files" do
    test_class = Class.new(Perron::Resource) do
      source comparisons: { primary_key: :code, mode: :combinations, extension: :md }

      def self.source_template(source)
        "test"
      end
    end

    Content.const_set(:MdComparison, test_class)

    test_class.generate_from_sources!

    assert_path_exists Rails.root.join("app/content/md_comparisons/a-b.md")
    assert_path_exists Rails.root.join("app/content/md_comparisons/a-c.md")
    assert_path_exists Rails.root.join("app/content/md_comparisons/b-c.md")
  ensure
    Content.send(:remove_const, :MdComparison) rescue nil
  end
end
