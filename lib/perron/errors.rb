module Perron
  module Errors
    class CollectionNotFoundError < StandardError; end

    class FileNotFoundError < StandardError; end

    class ResourceNotFoundError < StandardError; end

    class UnsupportedDataFormatError < StandardError; end

    class DataParseError < StandardError; end
  end
end
