# frozen_string_literal: true

require "rouge"
require "perron/html_processor/base"

module Perron
  class HtmlProcessor
    class SyntaxHighlight < HtmlProcessor::Base
      def process
        @html.css('pre > code[class*="language-"]').each do |code_block|
          language = code_block[:class][/(?<=language-)\S+/]

          next if language.blank?

          code_block.parent.replace(
            highlight(code_block.text, with: language)
          )
        end
      end

      private

      def highlight(code_block, with:)
        lexer = Rouge::Lexer.find(with) || Rouge::Lexers::PlainText.new

        Rouge::Formatters::HTMLPygments.new(::Rouge::Formatters::HTML.new).format(lexer.lex(code_block))
      end
    end
  end
end
