# frozen_string_literal: true

class DummyProcessor < Perron::HtmlProcessor::Base
  def process
    @html.css("p").add_class(@resource.metadata.processor_class || "processed-by-dummy")
  end
end
