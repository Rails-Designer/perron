gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

create_file "app/processors/copyable_code_processor.rb", <<~'RUBY'
class CopyableCodeProcessor < Perron::HtmlProcessor::Base
  def process
    @html.css("pre").each do |pre|
      next if skippable? pre

      id = "pre_#{Random.hex(4)}"

      button = Nokogiri::XML::Node.new("button", @html)
      button["type"] = "button"
      button["data-action"] = "copy"
      button["data-target"] = id
      button.content = "Copy"

      pre["id"] = id
      pre.add_previous_sibling(button)
    end
  end

  private

  def skippable?(pre)
    # add when the processor should skip this pre-element, e.g.
    # `pre["lang"] == "console"`
  end
end
RUBY
end
