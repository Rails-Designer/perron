module Perron
  module SuffixStripping
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
