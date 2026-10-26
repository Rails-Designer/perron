gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

create_file "app/processors/inject_processor.rb", <<~RUBY
class InjectProcessor < Perron::HtmlProcessor::Base
  def process
    return if content_too_short?
    return if injection_point.blank?

    injection_point.add_previous_sibling(Nokogiri::HTML.fragment(snippet))
  end

  private

  MINIMUM_CHARACTER_COUNT = 2_000

  def content_too_short?
    @html.text.size < MINIMUM_CHARACTER_COUNT
  end

  def injection_point
    return if h2_elements.empty?

    h2_elements.find { text_position_of(it) >= content_midpoint } || h2_elements.last
  end

  def snippet
    # Add whatever you want to inject,
    # e.g. a email form, an advertisement script, etc.
    "💉"
  end

  def h2_elements = @html.css("h2")

  def text_position_of(element) = @html.text.index(element.text).to_i

  def content_midpoint = @html.text.size / 2
end
RUBY
end
