gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  create_file "app/processors/card_processor.rb", <<~'TEXT', force: true
class CardProcessor < Perron::HtmlProcessor::Base
  include ActionView::Helpers::UrlHelper

  def process
    @html.css("p").each { cardify it }
  end

  private

  def cardify(node)
    content = node.content

    return unless content.match?(/\[!card/i)

    replace_outer node, with: content.gsub(/\[!card\s+([^\]]+)\]/i) { card resource($1) }
  end

  def card(resource)
    link_to Rails.application.routes.url_helpers.resource_path(resource), class: "card" do
      safe_join([
        tag.h5(resource.metadata.title, class: "title"),

        tag.p(resource.metadata.description, class: "description"),

        tag.time(resource.published_at, datetime: resource.published_at, class: "timestamp")
      ])
    end
  end

  def resource(id) = Content::Article.find!(id)

  def replace_outer(node, with:)
    node.replace(Nokogiri::XML::DocumentFragment.parse(with))
  end
end

TEXT

create_file "app/processors/card_processor.rb", <<~'TEXT', force: true
class CardProcessor < Perron::HtmlProcessor::Base
  include ActionView::Helpers::UrlHelper

  def process
    @html.css("p").each { cardify it }
  end

  private

  def cardify(node)
    content = node.content

    return unless content.match?(/\[!card/i)

    replace_outer node, with: content.gsub(/\[!card\s+([^\]]+)\]/i) { card resource($1) }
  end

  def card(resource)
    link_to Rails.application.routes.url_helpers.resource_path(resource), class: "card" do
      safe_join([
        tag.h5(resource.metadata.title, class: "title"),

        tag.p(resource.metadata.description, class: "description"),

        tag.time(resource.published_at, datetime: resource.published_at, class: "timestamp")
      ])
    end
  end

  def resource(id) = Content::Article.find!(id)

  def replace_outer(node, with:)
    node.replace(Nokogiri::XML::DocumentFragment.parse(with))
  end
end

TEXT
end
