class Content::Comparison < Perron::Resource
  source comparisons: { primary_key: :code, mode: :combinations }

  def self.source_template(source)
    <<~TEMPLATE
    ---
    comparison_1_code: #{source.comparisons_1.code}
    comparison_2_code: #{source.comparisons_2.code}
    ---

    # #{source.comparisons_1.name} vs #{source.comparisons_2.name}

    Price difference: $#{source.comparisons_1.price.to_i - source.comparisons_2.price.to_i}
    TEMPLATE
  end
end