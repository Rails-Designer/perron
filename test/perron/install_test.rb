require "test_helper"

class InstallTaskTest < ActiveSupport::TestCase
  def setup
    @tmpdir = File.expand_path("test/dummy/tmp/install")
    @install_dir = File.expand_path("lib/perron/install")

    FileUtils.mkdir_p(@tmpdir)
    FileUtils.mkdir_p("#{@tmpdir}/config/initializers")
    FileUtils.mkdir_p("#{@tmpdir}/app/content/data")

    File.write("#{@tmpdir}/Gemfile", "source 'https://rubygems.org'\n")
    File.write("#{@tmpdir}/.gitignore", "")
  end

  def test_creates_perron_initializer
    run_template

    assert File.exist?("#{@tmpdir}/config/initializers/perron.rb")
    assert_match(/Perron.configure do |config|/, File.read("#{@tmpdir}/config/initializers/perron.rb"))
  end

  def test_creates_data_folder_with_readme
    run_template

    assert File.exist?("#{@tmpdir}/app/content/data/README.md")
    content = File.read("#{@tmpdir}/app/content/data/README.md")

    assert_match(/<% Content::Data::Features.all.each do |feature| %>/, content)
    assert_match(/<%= render Content::Data::Features.all %>/, content)
  end

  def test_adds_markdown_gem_options_to_gemfile
    run_template

    content = File.read("#{@tmpdir}/Gemfile")
    assert_match(/# gem "commonmarker"/, content)
    assert_match(/# gem "kramdown"/, content)
    assert_match(/# gem "redcarpet"/, content)
  end

  def test_adds_output_folder_to_gitignore
    run_template

    content = File.read("#{@tmpdir}/.gitignore")
    assert_match(%r{/#{Perron.configuration.output}/}, content)
  end

  private

  def run_template
    Dir.chdir(@tmpdir) do
      FileUtils.cp("#{@install_dir}/initializer.rb.tt", 'config/initializers/perron.rb')
      FileUtils.cp("#{@install_dir}/README.md.tt", 'app/content/data/README.md')
      File.open("Gemfile", "a") do |file|
        file.write <<~RUBY

          # Perron supports Markdown rendering using one of the following gems.
          # Uncomment your preferred choice and run `bundle install`
          # gem "commonmarker"
          # gem "kramdown"
          # gem "redcarpet"
        RUBY
      end

      File.open(".gitignore", "a") do |file|
        file.write "/#{Perron.configuration.output}/\n"
      end
    end
  end
end
