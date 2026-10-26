module SvgHelper
  def svg(name, options = {})
    SvgRenderer.new(name, options).render
  end

  class SvgRenderer
    def initialize(name, options = {})
      @name, @options = name, options
      @file_path = Rails.root.join("app", "assets", "svg", "#{name}.svg")
    end

    def render
      return error("SVG not found: `#{@name}`") unless file_exists?

      fragment = Nokogiri::HTML::DocumentFragment.parse(File.read(@file_path))
      svg_element = fragment.at_css("svg")

      return error("Invalid SVG: `#{@name}`") if svg_element.blank?

      apply_options(to: svg_element)

      svg_element.to_html.html_safe
    end

    private

    def file_exists? = File.exist?(@file_path)

    def apply_options(to:)
      @options.each do |key, value|
        case value
        when Hash
          value.each { |nested_key, nested_value| to["#{key}-#{nested_key}"] = nested_value }
        else
          to[key.to_s] = value
        end
      end
    end

    def error(message) = "<!-- #{message} -->".html_safe
  end
end
