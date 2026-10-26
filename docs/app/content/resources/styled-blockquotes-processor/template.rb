gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

create_file "app/processors/styled_blockquote_processor.rb", <<-'RUBY'
  class StyledBlockquoteProcessor < Perron::HtmlProcessor::Base
    # uncomment if you use Rails Icons, see: https://github.com/Rails-Designer/rails_icons/
    # include RailsIcons::Helpers::IconHelper

    def process
      @html.css("blockquote").each { transform_to_styled it }
    end

    private

    # Add an `icon` key with a Rails Icons name to include an icon
    # Example: "note" => { class: "alert alert-note", icon: "information-circle" }
    def styles
      {
        "note" => {
          class: "alert alert-note"
        },

        "tip" => {
          class: "alert alert-tip"
        },

        "important" => {
          class: "alert alert-important"
        },

        "warning" => {
          class: "alert alert-warning"
        },

        "caution" => {
          class: "alert alert-caution"
        }
      }
    end

    def transform_to_styled(blockquote)
      paragraph = blockquote.at_css("p")
      text = paragraph&.inner_html&.strip
      marker = text&.match(/^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/i)

      return unless marker

      type = marker[1].downcase
      style = styles[type]

      paragraph.inner_html = paragraph.inner_html.sub(/^\[!#{type}\]\s*/i, "").sub(/^(<br>\s*)+/, "")
      blockquote["class"] = style[:class]

      blockquote.prepend_child(icon(style[:icon])) if style[:icon] && respond_to?(:icon)
    end
  end
RUBY
end
