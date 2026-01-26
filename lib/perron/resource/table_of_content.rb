# frozen_string_literal: true

module Perron
  class Resource
    module TableOfContent
      extend ActiveSupport::Concern

      def table_of_content(levels: %w[h1 h2 h3 h4 h5 h6])
        return [] if content.blank? || metadata.toc == false

        document = Nokogiri::HTML::DocumentFragment.parse(Markdown.render(content))
        headings = extract_headings from: document, levels: levels.join(", ")

        Builder.new.build(headings)
      end
      alias_method :table_of_contents, :table_of_content
      alias_method :toc, :table_of_content

      private

      Item = ::Data.define(:id, :text, :level, :children)

      class Builder
        def build(headings)
          parents = {0 => {children: []}}

          headings.each_with_object(parents[0][:children]) do |heading, _|
            parents.delete_if { |level, _| level >= heading.level }

            parent = parents[parents.keys.select { it < heading.level }.max || 0]

            (parent.is_a?(Hash) ? parent[:children] : parent.children) << heading

            parents[heading.level] = heading
          end
        end
      end
    end
  end
end
