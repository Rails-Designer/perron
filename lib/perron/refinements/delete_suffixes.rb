# frozen_string_literal: true

module Perron
  module Refinements
    module DeleteSuffixes
      refine String do
        def delete_suffixes(suffixes)
          suffixes
            .sort_by(&:length)
            .reverse_each
            .reduce(self, :delete_suffix)
        end
      end
    end
  end
end
