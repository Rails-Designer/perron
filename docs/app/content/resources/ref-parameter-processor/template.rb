gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

create_file "app/processors/ref_parameter_processor.rb", <<~RUBY
  class RefParameterProcessor < Perron::HtmlProcessor::Base
    def process
      @html.css("a").each do |link|
        href = link["href"]

        next if skippable?(href)

        link["href"] = uri_from href
      end
    end

    private

    # Add your default ref value here
    DEFAULT_REF = nil

    def skippable?(href)
      query = URI(href).query.to_s

      # when using absolute urls for your internal links, make sure to include
      # those as well e.g., `href.start_with?("https://example.com/")`
      href.blank? ||
        href.start_with?("/", "#", "mailto:") ||
        URI.decode_www_form(query).to_h.key?("ref")
    end

    def uri_from(href)
      return href if DEFAULT_REF.blank?

      URI(href).tap do |uri|
        params = URI.decode_www_form(uri.query || "").to_h
        params["ref"] = DEFAULT_REF.to_s
        uri.query = URI.encode_www_form(params)
      end.to_s
    end
  end
RUBY
end
