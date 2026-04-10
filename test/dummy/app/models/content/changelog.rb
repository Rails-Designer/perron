class Content::Changelog < Perron::Resource
  delegate :section, :position, to: :metadata

  adjacent_by :position, within: :section
end
