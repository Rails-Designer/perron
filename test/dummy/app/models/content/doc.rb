class Content::Doc < Perron::Resource
  delegate :section, :position, to: :metadata

  adjacent_by :position
end
