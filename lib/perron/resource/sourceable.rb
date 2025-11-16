# frozen_string_literal: true

module Perron
  class Resource
    module Sourceable
      extend ActiveSupport::Concern

      class_methods do
        def sources(*arguments)
          @source_definitions = parsed(*arguments)
        end
        alias_method :source, :sources

        def source_definitions
          @source_definitions || {}
        end

        def source_names = source_definitions.keys

        def generate_from_sources!
          return unless source_backed?

          combinations.each do |combo|
            content = content_with combo
            filename = filename_with combo

            FileUtils.mkdir_p(output_dir)
            File.write(output_dir.join("#{filename}.erb"), content)
          end
        end

        def source_backed? = source_names.any?

        private

        def parsed(*arguments)
          return {} if arguments.empty?

          arguments.flat_map { it.is_a?(Hash) ? it.to_a : [[it, {primary_key: :id}]] }.to_h
        end

        def combinations
          datasets = source_names.map { Perron::Site.data.public_send(it) }

          datasets.first.product(*datasets[1..])
        end

        def content_with(combo)
          data = source_names.each.with_index.to_h { |name, index| [name, combo[index]] }
          sources = Source.new(data)

          source_template(sources)
        end

        def filename_with(combo)
          source_names.each_with_index.map do |name, index|
            primary_key = source_definitions[name][:primary_key]

            combo[index].public_send(primary_key)
          end.join("-")
        end

        def output_dir = Perron.configuration.input.join(model_name.collection)
      end

      def source_backed? = self.class.source_backed?

      def sources
        @sources ||= begin
          data = self.class.source_definitions.each_with_object({}) do |(name, options), hash|
            primary_key = options[:primary_key]
            singular_name = name.to_s.singularize
            identifier = frontmatter["#{singular_name}_#{primary_key}"]
            hash[name] = Perron::Site.data.public_send(name).find { it.public_send(primary_key).to_s == identifier.to_s }
          end

          Source.new(data)
        end
      end

      def source_template(sources)
        raise NotImplementedError, "#{self.class.name} must implement #source_template"
      end

      class Source
        def initialize(data)
          @data = data
        end

        def method_missing(name, *arguments, &block)
          return super if arguments.any? || block
          return @data[name] if @data.key?(name)

          super
        end

        def respond_to_missing?(name, _) = @data.key?(name)
      end
      private_constant :Source
    end
  end
end
