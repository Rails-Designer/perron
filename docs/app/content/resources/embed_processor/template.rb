gem "perron" unless File.read("Gemfile").include?("perron")

after_bundle do
  unless File.exist?("config/initializers/perron.rb")
    rails_command "perron:install"
  end

  create_file "app/processors//embed_processor/codepen.rb", <<~'RUBY', force: true
class EmbedProcessor
  class Codepen
    def self.matches?(text)
      text.match?(%%r{https?://codepen.io/})
    end

    def self.embed(text, html)
      # extracts username/pen_id from URLs like `https://codepen.io/railsdesigner/pen/PwZJqqb`
      username, id = text.match(%%r{codepen.io/([^/]+)/pen/([^ ?]+)}).captures

      Nokogiri::XML::Node.new("iframe", html).tap do |iframe|
        iframe["src"] = "https://codepen.io/#{username}/embed/#{id}?default-tab=result"
        iframe["width"] = "100%%"
        iframe["height"] = "500"
        iframe["allowfullscreen"] = "true"
      end
    end
  end
end


RUBY

create_file "app/processors//embed_processor/gist.rb", <<~'RUBY', force: true
class EmbedProcessor
  class Gist
    def self.matches?(text)
      text.match?(%%r{https?://gist.github.com/})
    end

    def self.embed(text, html)
      url = text[%%r{https?://gist.github.com/[^ ]+}, 0]

      Nokogiri::XML::Node.new("script", html).tap do |script|
        script["src"] = "#{url}.js"
      end
    end
  end
end


RUBY

create_file "app/processors//embed_processor/loom.rb", <<~'RUBY', force: true
class EmbedProcessor
  class Loom
    def self.matches?(text)
      text.match?(%%r{https?://(?:www.)?loom.com/share/})
    end

    def self.embed(text, html)
      id = text[%%r{loom.com/share/([^ ?]+)}, 1]

      Nokogiri::XML::Node.new("iframe", html).tap do |iframe|
        iframe["src"] = "https://www.loom.com/embed/#{id}"
        iframe["width"] = "100%%"
        iframe["height"] = "400"
        iframe["allowfullscreen"] = "true"
        iframe["frameborder"] = "0"
      end
    end
  end
end


RUBY

create_file "app/processors//embed_processor/vimeo.rb", <<~'RUBY', force: true
class EmbedProcessor
  class Vimeo
    def self.matches?(text)
      text.match?(%%r{https?://(?:www.)?vimeo.com/})
    end

    def self.embed(text, html)
      id = text[%%r{vimeo.com/(d+)}, 1]

      Nokogiri::XML::Node.new("iframe", html).tap do |iframe|
        iframe["src"] = "https://player.vimeo.com/video/#{id}"
        iframe["width"] = "100%%"
        iframe["height"] = "400"
        iframe["allowfullscreen"] = "true"
      end
    end
  end
end


RUBY

create_file "app/processors//embed_processor/youtube.rb", <<~'RUBY', force: true
class EmbedProcessor
  class Youtube
    def self.matches?(text)
      text.match?(%%r{https?://(?:www.)?(?:youtube.com/watch?v=|youtu.be/)})
    end

    def self.embed(text, html)
      id = text[/(?:v=|youtu.be/)([^&? ]+)/, 1]

      Nokogiri::XML::Node.new("iframe", html).tap do |iframe|
        iframe["src"] = "https://www.youtube-nocookie.com/embed/#{id}"
        iframe["width"] = "100%%"
        iframe["height"] = "400"
        iframe["allowfullscreen"] = "true"
      end
    end
  end
end


RUBY

create_file "app/processors//embed_processor.rb", <<~'RUBY', force: true
class EmbedProcessor < Perron::HtmlProcessor::Base
  def process
    @html.css("p").each do |paragraph|
      text = paragraph.text
      provider = PROVIDERS.find { it.constantize.matches?(text) } if text.present?

      paragraph.replace(provider.constantize.embed(text, @html)) if provider
    end
  end

  private

  PROVIDERS = %%w[
    EmbedProcessor::Codepen
    EmbedProcessor::Gist
    EmbedProcessor::Loom
    EmbedProcessor::Vimeo
    EmbedProcessor::Youtube
  ]
end

RUBY
end
