# frozen_string_literal: true

module Perron
  module Site
    class Builder
      class Feeds
        module Author
          private

          def author(resource)
            author = (resource&.respond_to?(:author) && resource.author) ||
              feed_configuration.author

            Author.new(author) if author
          end

          class Author
            def initialize(author)
              @author = author
            end

            def name
              @author.respond_to?(:metadata) ? @author.metadata.name : @author[:name]
            end

            def email
              @author.respond_to?(:metadata) ? @author.metadata.email : @author[:email]
            end

            def url
              @author.respond_to?(:metadata) ? @author.metadata.url : @author[:url]
            end

            def avatar
              @author.respond_to?(:metadata) ? @author.metadata.avatar : @author[:avatar]
            end
          end
        end
      end
    end
  end
end
