gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

create_file "app/processors/nofollow_processor.rb", <<~RUBY
  class NofollowProcessor < Perron::HtmlProcessor::Base
    def process
      @html.css("a").each do |link|
        next if skippable? link

        link["rel"] = "nofollow"
      end
    end

    private

    def skippable?(link)
      href = link["href"]

      # when using absolute urls for your internal links, make sure to include
      # those as well e.g., `href.start_with?("https://example.com/")`
      href.blank? ||
        href.start_with?("/", "#", "mailto:") ||
        link["rel"].present?
    end
  end
RUBY
end
