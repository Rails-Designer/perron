class LabelProcessor < Perron::HtmlProcessor::Base
  include ActionView::Helpers::TagHelper

  def process
    @html.css("p").each { labelize it }
  end

  private

  def labelize(node)
    content = node.content

    return unless content.match?(/\[!label/i)

    labeled_content = content.gsub(/\[!label(?::(\w+))?\s+([^\]]+)\]/i) do
      create_label(with: $2, variant: $1)
    end

    node.inner_html = labeled_content
  end

  def create_label(with:, variant: nil)
    attributes = { class: "inline-block px-3.5 py-0.5 text-xs font-semibold text-emerald-800 bg-gradient-to-r from-white to-emerald-50 ring ring-emerald-100 rounded-full" }
    attributes[:"data-variant"] = variant if variant

    content_tag(:span, with, attributes)
  end
end
