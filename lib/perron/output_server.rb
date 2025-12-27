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

      [
        200,

        {
          "Content-Type" => "text/html; charset=utf-8",
          "Content-Length" => content.bytesize.to_s
        },

        [content]
      ]
    end

    def enabled? = Dir.exist?(output_path)

    def output_path
      @output_path ||= Rails.root.join(Perron.configuration.output)
    end
  end
end
