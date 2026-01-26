# frozen_string_literal: true

require "perron/resource/related/stop_words"

module Perron
  module Site
    class Resource
      class Related
        @collection_caches = {}

        def self.cache_for(collection_name)
          @collection_caches[collection_name] ||= { tfidf_vectors: {}, inverse_document_frequency: nil }
        end

        def initialize(resource)
          @resource = resource
          @collection = resource.collection
          @cache = self.class.cache_for(@collection.name)
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
          vectors = @cache[:tfidf_vectors]
          slug = target_resource.slug

          return vectors[slug] if vectors.key?(slug)

          tokens = tokenize_content(target_resource)
          token_count = tokens.size

          return vectors[slug] = {} if token_count.zero?

          term_count = Hash.new(0)

          tokens.each { |token| term_count[token] += 1 }

          tfidf_vector = {}

          term_count.each do |term, count|
            terms = count.to_f / token_count

            tfidf_vector[term] = terms * inverse_document_frequency[term]
          end

          vectors[slug] = tfidf_vector
        end

        def tokenize_content(target_resource)
          @tokenized_content ||= {}
          slug = target_resource.slug

          return @tokenized_content[slug] if @tokenized_content.key?(slug)
          return @tokenized_content[slug] = [] if target_resource.content.blank?

          content = target_resource.content.gsub(/<[^>]*>/, " ")
          tokens = content.downcase.scan(/\w+/).reject { StopWords.all.include?(it) || it.length < 3 }

          @tokenized_content[slug] = tokens
        end

        def inverse_document_frequency
          return @cache[:inverse_document_frequency] if @cache[:inverse_document_frequency]

          @cache[:inverse_document_frequency] = begin
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
