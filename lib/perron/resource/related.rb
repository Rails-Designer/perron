# frozen_string_literal: true

require "perron/resource/related/stop_words"

module Perron
  module Site
    class Resource
      # Finds related resources using TF-IDF cosine similarity.
      #
      # Pre-normalizes vectors so cosine similarity reduces to a dot product,
      # then builds a symmetric similarity matrix once per collection.
      # Results are cached at the class level so the O(n²) comparison
      # is paid once, not once per resource.
      class Related
        Cache = Struct.new(:resources, :similarity_matrix, :fingerprint)

        @collection_caches = {}

        def self.cache_for(collection_name)
          clear_cache!(collection_name) if stale?(collection_name)
          @collection_caches[collection_name] ||= Cache.new(nil, nil, content_fingerprint(collection_name))
        end

        def self.clear_cache!(collection_name)
          @collection_caches.delete(collection_name)
        end

        def self.stale?(collection_name)
          @collection_caches[collection_name]&.fingerprint != content_fingerprint(collection_name)
        end

        def self.content_fingerprint(collection_name)
          path = File.join(Perron.configuration.input, collection_name)
          files = Dir.glob(File.join(path, "**", "*.*"))
          [files.size, files.map { File.mtime(it) }.max]
        end

        def initialize(resource)
          @resource = resource
          @collection = resource.collection
          @cache = self.class.cache_for(@collection.name)
        end

        def find(limit: 5)
          scores = similarity_matrix[@resource.slug] || {}

          resources
            .reject { it.slug == @resource.slug }
            .sort_by { -(scores[it.slug] || 0.0) }
            .first(limit)
        end

        private

        def resources = @cache.resources ||= @collection.resources

        def similarity_matrix = @cache.similarity_matrix ||= build_similarity_matrix

        def build_similarity_matrix
          vectors = resources.to_h { [it.slug, normalize(tfidf_vector_for(it))] }
          matrix = Hash.new { |h, k| h[k] = {} }

          slugs = vectors.keys
          slugs.each_with_index do |slug_a, i|
            next if vectors[slug_a].empty?

            slugs[(i + 1)..].each do |slug_b|
              next if vectors[slug_b].empty?

              score = dot_product(vectors[slug_a], vectors[slug_b])
              matrix[slug_a][slug_b] = score
              matrix[slug_b][slug_a] = score
            end
          end

          matrix
        end

        def dot_product(vec_a, vec_b)
          score = 0.0
          vec_a.each_key { score += vec_a[it] * vec_b[it] if vec_b.key?(it) }
          score
        end

        def normalize(vector)
          return {} if vector.empty?

          magnitude = Math.sqrt(vector.values.sum { it**2 })
          return {} if magnitude.zero?

          vector.transform_values { it / magnitude }
        end

        def tfidf_vector_for(resource)
          tokens = tokenize(resource)
          return {} if tokens.empty?

          token_count = tokens.size.to_f

          tokens.tally.to_h { |term, count| [term, (count / token_count) * inverse_document_frequency[term]] }
        end

        def tokenize(resource)
          return [] if resource.content.blank?

          resource.content.gsub(/<[^>]*>/, " ").downcase.scan(/\w+/).reject { StopWords.all.include?(it) || it.length < 3 }
        end

        def inverse_document_frequency
          @inverse_document_frequency ||= begin
            doc_frequency = Hash.new(0)
            resources.each { tokenize(it).uniq.each { doc_frequency[it] += 1 } }

            total = resources.size.to_f
            doc_frequency.transform_values { Math.log(total / (1 + it)) }
          end
        end
      end
    end
  end
end
