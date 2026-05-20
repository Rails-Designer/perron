# frozen_string_literal: true

module Perron
  module Site
    class Validate
      def initialize(collections: Perron::Site.collections)
        @collections = collections
        @failures = []
      end

      def validate
        @collections.each { validate_collection it }

        [
          puts,
          failures_report,
          puts
        ].compact_blank.join

        puts [
          "Validation finished",
          (" with #{@failures.count} failures" if failed?)
        ].join
      end

      def failed? = @failures.any?

      private

      Failure = ::Data.define(:identifier, :errors)

      GREEN = "\e[32m"
      RED = "\e[31m"
      RESET = "\e[0m"

      def validate_collection(collection)
        collection.resources.each do |resource|
          resource.validate ? success : failed(resource)
        rescue Psych::SyntaxError => error
          render_yaml error, resource.file_path
        end
      rescue Psych::SyntaxError => error
        render_yaml error, "unknown"
      end

      def success = print "#{GREEN}.#{RESET}"

      def failed(resource)
        print "#{RED}F#{RESET}"

        @failures << Failure.new(
          identifier: resource.file_path,
          errors: resource.errors.respond_to?(:full_messages) ? resource.errors.full_messages : []
        )
      end

      def render_yaml(error, identifier)
        print "#{RED}F#{RESET}"

        line_info = error.line ? " at line #{error.line}" : ""
        column_info = error.column ? ", column #{error.column}" : ""

        @failures << Failure.new(
          identifier: identifier,
          errors: ["Invalid YAML#{line_info}#{column_info}: #{error.problem}"]
        )
      end

      def failures_report
        @failures.each do |failure|
          puts "Resource: #{failure.identifier}"

          failure.errors.each do |error_message|
            puts "  - #{error_message}"
          end
        end
      end
    end
  end
end
