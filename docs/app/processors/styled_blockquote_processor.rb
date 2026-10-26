class StyledBlockquoteProcessor < Perron::HtmlProcessor::Base
  include ActionView::Helpers::TagHelper
  include RailsIcons::Helpers::IconHelper

  def process
    @html.css("blockquote").each { transform_to_styled it }
  end

  private

  def styles
    base_classes = "flex items-baseline gap-x-3 px-3 py-2 text-base font-normal border border-white/50 ring ring-offset-0 rounded-md"

    {
      "note" => {
        class: class_names(base_classes, "ring-blue-200/60 bg-blue-50 text-blue-900"),
        icon: "info"
      },

      "tip" => {
        class: class_names(base_classes, "ring-green-200/60 bg-green-50 text-green-900"),
        icon: "lightbulb"
      },

      "important" => {
        class: class_names(base_classes, "ring-purple-200/60 bg-purple-50 text-purple-900"),
        icon: "warning-circle"
      },

      "warning" => {
        class: class_names(base_classes, "ring-yellow-200/60 bg-yellow-50 text-yellow-900"),
        icon: "warning"
      },

      "caution" => {
        class: class_names(base_classes, "ring-red-200/60 bg-red-50 text-red-900"),
        icon: "shield-warning"
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

    blockquote.prepend_child(sprite_icon(style[:icon], class: "translate-y-0.5 size-4 shrink-0 opacity-75")) if style[:icon] && respond_to?(:sprite_icon)
  end
end
