class NofollowProcessor < Perron::HtmlProcessor::Base
  def process
    @html.css("a").each do |link|
      next if skippable? link

      link["rel"] = "nofollow"
    end
  end

  private

  def skippable?(link)
    href = link["href"]

    href.blank? ||
      href.start_with?("https://perron.railsdesigner.com") ||
      href.start_with?("/", "#", "mailto:") ||
      link["rel"].present?
  end
end
