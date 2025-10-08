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
          (" with #{@failures.count} failures" if @failures.any?),
          "."
        ].join
      end

      private

      Failure = ::Data.define(:identifier, :errors)

      GREEN = "\e[32m"
      RED = "\e[31m"
      RESET = "\e[0m"

      def validate_collection(collection)
        collection.resources.each do |resource|
          resource.validate ? success : failed(resource)
        end
      end

      def success = print "#{GREEN}.#{RESET}"

      def failed(resource)
        print "#{RED}F#{RESET}"

        errors = []

        if resource.respond_to?(:errors) && resource.errors.respond_to?(:full_messages) && resource.errors.any?
          errors = resource.errors.full_messages
        end

        @failures << Failure.new(identifier: resource.file_path, errors: errors)
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
