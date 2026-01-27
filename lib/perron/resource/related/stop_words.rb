# frozen_string_literal: true

module Perron
  module Site
    class Resource
      class Related
        module StopWords
          ALL = Set[
            "a", "about", "above", "after", "again", "against", "all", "am",
            "an", "and", "any", "are", "as", "at", "be", "because", "been",
            "before", "being", "below", "between", "both", "but", "by", "can",
            "did", "do", "does", "doing", "down", "during", "each", "few",
            "for", "from", "further", "had", "has", "have", "having", "he",
            "her", "here", "hers", "herself", "him", "himself", "his", "how",
            "i", "if", "in", "into", "is", "it", "its", "itself", "just",
            "me", "more", "most", "my", "myself", "no", "nor", "not", "now",
            "of", "off", "on", "once", "only", "or", "other", "our", "ours",
            "ourselves", "out", "over", "own", "s", "same", "she", "should",
            "so", "some", "such", "t", "than", "that", "the", "their",
            "theirs", "them", "themselves", "then", "there", "these", "they",
            "this", "those", "through", "to", "too", "under", "until", "up",
            "very", "was", "we", "were", "what", "when", "where", "which",
            "while", "who", "whom", "why", "will", "with", "you", "your",
            "yours", "yourself", "yourselves"
          ].freeze

          module_function

          def all = ALL
        end
      end
    end
  end
end
