module Perron
  module Errors
    class CollectionNotFoundError < StandardError; end

    class FileNotFoundError < StandardError; end

    class ResourceNotFoundError < StandardError; end
  end
end
