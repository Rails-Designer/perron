# frozen_string_literal: true

module Perron
  class Metatags
    include ActionView::Helpers::TagHelper

    def initialize(data)
      @data = data
    end

    def render(options = {})
      keys = tags.keys
        .then { options[:only] ? it & options[:only].map(&:to_sym) : it }
        .then { options[:except] ? it - options[:except].map(&:to_sym) : it }

      safe_join(keys.filter_map { tags[it].presence }, "\n")
    end

    private

    def tags
      @tags ||= {
        title: title_tag(@data[:title]),

        description: meta_tag(name: "description", content: @data[:description]),
        article_published: meta_tag(property: "article:published_time", content: @data[:article_published_time]),

        og_title: meta_tag(property: "og:title", content: @data[:og_title]),
        og_type: meta_tag(property: "og:type", content: @data[:og_type]),
        og_url: meta_tag(property: "og:url", content: @data[:og_url]),
        og_image: meta_tag(property: "og:image", content: @data[:og_image]),
        og_description: meta_tag(property: "og:description", content: @data[:og_description]),
        og_site_name: meta_tag(property: "og:site_name", content: @data[:og_site_name]),
        og_logo: meta_tag(property: "og:logo", content: @data[:og_logo]),
        og_author: meta_tag(property: "og:author", content: @data[:og_author]),
        og_locale: meta_tag(property: "og:locale", content: @data[:og_locale]),

        twitter_card: meta_tag(name: "twitter:card", content: @data[:twitter_card]),
        twitter_title: meta_tag(name: "twitter:title", content: @data[:twitter_title]),
        twitter_description: meta_tag(name: "twitter:description", content: @data[:twitter_description]),
        twitter_image: meta_tag(name: "twitter:image", content: @data[:twitter_image])
      }
    end

    def title_tag(content)
      config = Perron.configuration
      resource_title = content.to_s.strip
      title_suffix = config.metadata.title_suffix&.strip
      suffix = (title_suffix if title_suffix.present? && resource_title != title_suffix)

      tag.title([resource_title, suffix].compact.join(config.metadata.title_separator))
    end

    def meta_tag(attributes)
      return if attributes[:content].blank?

      tag.meta(**attributes)
    end
  end
end
