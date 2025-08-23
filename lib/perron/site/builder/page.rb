# frozen_string_literal: true

require "rack/mock"

module Perron
  module Site
    class Builder
      class Page
        def initialize(path)
          @output_path, @path = Rails.root.join(Perron.configuration.output), path
        end

        def render
          action = route_info[:action]
          request = ActionDispatch::Request.new(env)
          response = ActionDispatch::Response.new

          request.path_parameters = route_info

          controller.dispatch(action, request, response)

          return puts "  ❌ ERROR: Request failed for '#{@path}' (Status: #{response.status})" unless response.successful?

          save_html(response.body)
        rescue => error
          puts "  ❌ ERROR: Failed to generate page for '#{@path}'. Details: #{error.class} - #{error.message}\n#{error.backtrace.first(3).join("\n")}"
        end

        private

        def save_html(html)
          directory_path = @output_path.join(@path.delete_prefix("/"))
          file_path = directory_path.join("index.html")

          FileUtils.mkdir_p(directory_path)
          File.write(file_path, html)

          print "\e[32m.\e[0m"
        end

        def route_info
          @route_info ||= Rails.application.routes.recognize_path(@path)
        end

        def env = Rack::MockRequest.env_for(@path, "HTTP_HOST" => Perron.configuration.default_url_options[:host])

        def controller = "#{route_info[:controller]}_controller".classify.constantize.new
      end
    end
  end
end
