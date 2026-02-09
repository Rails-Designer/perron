# frozen_string_literal: true

module Perron
  class OutputServer
    def initialize(app)
      @app = app
    end

    def call(environment)
      return @app.call(environment) if disabled?

      static_file(environment).then do |file|
        file ? serve(file) : @app.call(environment)
      end
    end

    private

    def disabled? = !enabled?

    def static_file(environment)
      request_path = Rack::Request.new(environment).path_info
      file_path = File.join(output_path, request_path, "index.html")

      File.file?(file_path) ? file_path : nil
    end

    def serve(file_path)
      content = File.read(file_path)
      injected_content = inject_preview_indicator(content)

      [
        200,

        {
          "Content-Type" => "text/html; charset=utf-8",
          "Content-Length" => injected_content.bytesize.to_s
        },

        [injected_content]
      ]
    end

    def enabled? = Dir.exist?(output_path)

    def inject_preview_indicator(content)
      content.gsub(/<title>(.*?)<\/title>/i, "<title>[PREVIEW] \\1</title>")
    end

    def output_path
      @output_path ||= Rails.root.join(Perron.configuration.output)
    end
  end
end
