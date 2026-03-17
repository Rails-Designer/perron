# frozen_string_literal: true

require "nokogiri"
require "perron/site/builder/feeds/author"
require "perron/site/builder/feeds/template"

module Perron
  module Site
    class Builder
      class Feeds
        class Atom
          include Feeds::Author
          include Feeds::Template

          def initialize(collection:)
            @collection = collection
            @configuration = Perron.configuration
          end

          def generate
            return if resources.empty?

            if (template = find_template("atom"))
              return render(template, feed_configuration)
            end

            Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
              xml.feed(xmlns: "http://www.w3.org/2005/Atom") do
                xml.generator "Perron", uri: @configuration.url, version: Perron::VERSION
                xml.id current_feed_url
                xml.title feed_configuration.title.presence || @configuration.site_name
                xml.subtitle feed_configuration.description.presence || @configuration.site_description
                xml.link href: current_feed_url, rel: "self", type: "application/atom+xml"
                xml.link href: @configuration.url, rel: "alternate", type: "text/html"
                xml.updated resources.first&.published_at&.iso8601 || Time.current.iso8601

                feed_author = feed_configuration.author || {
                  name: @configuration.site_name,
                  email: "noreply@#{URI.parse(@configuration.url).host}"
                }

                xml.author do
                  xml.name feed_author[:name] if feed_author[:name]
                  xml.email feed_author[:email] if feed_author[:email]
                end

                resources.each do |resource|
                  xml.entry do
                    xml.title resource.metadata.title
                    xml.link href: url_for_resource(resource), rel: "alternate", type: "text/html"
                    xml.published resource.published_at&.iso8601
                    xml.updated (resource.metadata.updated_at || resource.published_at)&.iso8601
                    xml.id url_for_resource(resource) || "#{@configuration.url}/posts/#{resource.id}"

                    if (entry_author = author(resource))
                      xml.author do
                        xml.name entry_author.name if entry_author.name
                        xml.email entry_author.email if entry_author.email
                      end
                    end

                    if (base_url = url_for_resource(resource))
                      xml.content :type => "html", "xml:base" => base_url do
                        xml.cdata(Perron::Markdown.render(resource.content))
                      end
                    else
                      xml.content type: "html" do
                        xml.cdata(Perron::Markdown.render(resource.content))
                      end
                    end

                    resource.metadata.tags&.each do |tag|
                      xml.category term: tag
                    end
                  end
                end
              end
            end.to_xml
          end

          private

          def resources
            @resource ||= @collection.resources
              .reject { it.metadata.feed == false }
              .sort_by { it.metadata.published_at || it.metadata.updated_at || Time.current }
              .reverse
              .take(feed_configuration.max_items)
          end

          def url_for_resource(resource)
            routes
              .polymorphic_url(resource, **@configuration.default_url_options.merge(ref: feed_configuration.ref))
              .delete_suffix("?ref=")
          rescue
            nil
          end

          def current_feed_url
            path = feed_configuration.path || "feed.atom"

            URI.join(@configuration.url, path).to_s
          end

          def feed_configuration = @collection.configuration.feeds.atom

          def routes = Rails.application.routes.url_helpers
        end
      end
    end
  end
end
