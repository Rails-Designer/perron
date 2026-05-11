# frozen_string_literal: true

require "rack/mock"

module Perron
  module Site
    class Builder
      class Page
        Result = Struct.new(:success, :path, :error, :duration, keyword_init: true)

        def initialize(path, benchmark: nil)
          @output_path = Rails.root.join(Perron.configuration.output)
          @path = path
          @benchmark = benchmark
        end

        def render
          start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          action = route_info[:action]
          request = ActionDispatch::Request.new(env)
          response = ActionDispatch::Response.new

          request.path_parameters = route_info

          controller.dispatch(action, request, response)

          unless response.successful?
            return record_result(success: false, error: "Request failed (Status: #{response.status})", start_time: start_time)
          end

          save_html(response.body)

          record_result(success: true, start_time: start_time)
        rescue => error
          record_result(success: false, error: "#{error.class} - #{error.message}", start_time: start_time)
        end

        private

        def record_result(success:, start_time:, error: nil)
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

          @benchmark&.record_page(@path, duration)

          Result.new(success: success, path: @path, error: error, duration: duration)
        end

        def save_html(html)
          prefixless_path = @path.delete_prefix("/")

          file_path = @output_path.join(prefixless_path)
          file_path = file_path.join("index.html") if File.extname(prefixless_path).empty?

          FileUtils.mkdir_p(file_path.dirname)
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
