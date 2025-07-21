# frozen_string_literal: true

module Perron
  class Metatags
    include ActionView::Helpers::TagHelper

    def initialize(resource)
      @resource = resource
      @config = Perron.configuration
    end

    def render(options = {})
      keys = tags.keys
        .then { options[:only] ? it & options[:only].map(&:to_sym) : it }
        .then { options[:except] ? it - options[:except].map(&:to_sym) : it }

      safe_join(keys.filter_map { tags[it].presence }, "\n")
    end

    private

    FRONTMATTER_KEY_MAP = {
      "locale" => %w[og:locale],
      "image" => %w[og:image twitter:image],
      "author" => %w[og:author]
    }.freeze

    def tags
      @tags ||= begin
        frontmatter = @resource&.metadata&.stringify_keys || {}
        defaults = @config.metadata

        title = frontmatter["title"] || defaults["title"] || @config.site_name || Rails.application.name.underscore.camelize
        type = frontmatter["type"] || defaults["type"]
        description = frontmatter["description"] || defaults["description"]
        logo = frontmatter["logo"] || defaults["logo"]
        author = frontmatter["author"] || defaults["author"]
        image = frontmatter["image"] || defaults["image"]
        locale = frontmatter["locale"] || defaults["locale"]
        og_image = frontmatter["og:image"] || image
        twitter_image = frontmatter["twitter:image"] || og_image

        {
          title: title_tag(title),
          description: meta_tag(name: "description", content: description),
          article_published: meta_tag(property: "article:published_time", content: @resource&.published_at),

          og_title: meta_tag(property: "og:title", content: frontmatter["og:title"] || title),
          og_type: meta_tag(property: "og:type", content: frontmatter["og:type"] || type),
          og_url: meta_tag(property: "og:url", content: canonical_url),
          og_image: meta_tag(property: "og:image", content: og_image),

          og_description: meta_tag(property: "og:description", content: frontmatter["og:description"] || description),
          og_site_name: meta_tag(property: "og:site_name", content: @config.site_name),
          og_logo: meta_tag(property: "og:logo", content: frontmatter["og:logo"] || logo),
          og_author: meta_tag(property: "og:author", content: frontmatter["og:author"] || author),
          og_locale: meta_tag(property: "og:locale", content: frontmatter["og:locale"] || locale),

          twitter_card: meta_tag(name: "twitter:card", content: frontmatter["twitter:card"] || "summary_large_image"),
          twitter_title: meta_tag(name: "twitter:title", content: frontmatter["twitter:title"] || title),
          twitter_description: meta_tag(name: "twitter:description", content: frontmatter["twitter:description"] || description),
          twitter_image: meta_tag(name: "twitter:image", content: twitter_image)
        }
      end
    end

    def title_tag(content)
      resource_title = content.to_s.strip
      title_suffix = Perron.configuration.metadata.title_suffix&.strip

      suffix = (title_suffix if title_suffix.present? && resource_title != title_suffix)

      tag.title([resource_title, suffix].compact.join(Perron.configuration.metadata.title_separator))
    end

    def meta_tag(attributes)
      return if attributes[:content].blank?

      tag.meta(**attributes)
    end

    def canonical_url
      url_options = @config.default_url_options
      base_url = "#{url_options[:protocol]}://#{url_options[:host]}"
      url = URI.join(base_url, @resource&.path).to_s
      has_extension = URI(url).path.split("/").last&.include?(".")

      url.then { (url_options[:trailing_slash] && !it.end_with?("/") && !has_extension) ? "#{it}/" : it }
    end
  end
end
