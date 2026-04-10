class Content::Article < Perron::Resource
  SECTIONS = %w[getting_started content metadata]

  delegate :section, :position, to: :metadata

  adjacent_by :position, within: { section: SECTIONS }
end
