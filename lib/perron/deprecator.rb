# frozen_string_literal: true

module Perron
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("1.3.0", "Perron")
  end
end
