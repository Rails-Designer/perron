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
          info = route_info
          return puts "  ❌ ERROR: No route matches '#{@path}'" unless info

          request = ActionDispatch::Request.new(env)
          request.path_parameters = info

          matching_route = matching_route_for(request)
          return puts "  ❌ ERROR: No route matches '#{@path}'" unless matching_route

          return render_rack_route(matching_route) unless matching_route.defaults[:controller]

          response = ActionDispatch::Response.new

          controller.dispatch(info[:action], request, response)

          return puts "  ❌ ERROR: Request failed for '#{@path}' (Status: #{response.status})" unless response.successful?

          save_html(response.body)
        rescue => error
          puts "  ❌ ERROR: Failed to generate page for '#{@path}'. Details: #{error.class} - #{error.message}\n#{error.backtrace.first(3).join("\n")}"
        end

        private

        def matching_route_for(request)
          Rails.application.routes.router.recognize(
            ActionDispatch::Request.new(request.env.merge("PATH_INFO" => request.path_info.chomp("/").presence || "/"))
          ) { |route, _parameters| return route }

          nil
        end

        def render_rack_route(route)
          request = ActionDispatch::Request.new(env)
          request.path_parameters = route.defaults

          status, _headers, body = Rails.application.routes.call(request.env)

          return puts "  ❌ ERROR: Request failed for '#{@path}' (Status: #{status})" unless (200...300).cover?(status)

          save_html(html_from(body))
        rescue => error
          puts "  ❌ ERROR: Failed to generate page for '#{@path}'. Details: #{error.class} - #{error.message}\n#{error.backtrace.first(3).join("\n")}"
        end

        def html_from(body)
          body.respond_to?(:body) ? body.body : Array(body).join
        end

        private

        def save_html(html)
          prefixless_path = @path.delete_prefix("/")

          file_path = @output_path.join(prefixless_path)
          file_path = file_path.join("index.html") if File.extname(prefixless_path).empty?

          FileUtils.mkdir_p(file_path.dirname)
          File.write(file_path, html)

          print "\e[32m.\e[0m"
        end

        def route_info
          @route_info ||= recognize_path_with_pagination_fallback(@path)
        end

        def recognize_path_with_pagination_fallback(path)
          Rails.application.routes.recognize_path(path)
        rescue ActionController::RoutingError
          return nil unless (match = path.match(/\/(.+)\/page\/(\d+)\//))

          base_path = "/#{match[1]}"
          page_number = match[2].to_i

          Rails.application.routes.recognize_path(base_path).tap do |route_info|
            route_info[:page] = page_number
          end
        end

        def env = Rack::MockRequest.env_for(@path, "HTTP_HOST" => Perron.configuration.default_url_options[:host])

        def controller = "#{route_info[:controller]}_controller".classify.constantize.new
      end
    end
  end
end
