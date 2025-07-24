# frozen_string_literal: true

class DummyProcessor < Perron::HtmlProcessor::Base
  def process
    @html.css("p").add_class("processed-by-dummy")
  end
end
