# frozen_string_literal: true

require "perron/resource/related/stop_words"

module Perron
  module Site
    class Resource
      class Related
        def initialize(resource)
          @resource = resource
          @collection = resource.collection
        end

        def find(limit: 5)
          @collection.resources
            .reject { it.slug == @resource.slug }
            .map { [it, cosine_similarities_for(@resource, it)] }
            .sort_by { |_, score| -score }
            .map(&:first)
            .first(limit)
        end

        private

        def cosine_similarities_for(resource_one, resource_two)
          first_vector = tfidf_vector_for(resource_one)
          second_vector = tfidf_vector_for(resource_two)

          return 0.0 if first_vector.empty? || second_vector.empty?

          dot_product = 0.0

          first_vector.each_key { dot_product += first_vector[it] * second_vector[it] if second_vector.key?(it) }

          first_magnitude = Math.sqrt(first_vector.values.sum { it**2 })
          second_magnitude = Math.sqrt(second_vector.values.sum { it**2 })
          denominator = first_magnitude * second_magnitude

          return 0.0 if denominator.zero?

          dot_product / denominator
        end

        def tfidf_vector_for(target_resource)
          @tfidf_vectors ||= {}

          return @tfidf_vectors[target_resource] if @tfidf_vectors.key?(target_resource)

          tokens = tokenize_content(target_resource)
          token_count = tokens.size

          return {} if token_count.zero?

          term_count = Hash.new(0)

          tokens.each { |token| term_count[token] += 1 }

          tfidf_vector = {}

          term_count.each do |term, count|
            terms = count.to_f / token_count

            tfidf_vector[term] = terms * inverse_document_frequency[term]
          end

          @tfidf_vectors[target_resource] = tfidf_vector
        end

        def tokenize_content(target_resource)
          @tokenized_content ||= {}

          return @tokenized_content[target_resource] if @tokenized_content.key?(target_resource)

          content = target_resource.content.gsub(/<[^>]*>/, " ")
          tokens = content.downcase.scan(/\w+/).reject { StopWords.all.include?(it) || it.length < 3 }

          @tokenized_content[target_resource] = tokens
        end

        def inverse_document_frequency
          @inverse_document_frequency ||= begin
            resource_frequency = Hash.new(0)

            @collection.resources.each { tokenize_content(it).uniq.each { resource_frequency[it] += 1 } }

            frequencies = {}
            total_resources = @collection.resources.size

            resource_frequency.each do |term, frequency|
              frequencies[term] = Math.log(total_resources.to_f / (1 + frequency))
            end

            frequencies
          end
        end
      end
    end
  end
end
