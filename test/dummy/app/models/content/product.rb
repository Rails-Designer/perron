class Content::Product < Perron::Resource
  sources :countries, products: { primary_key: :code }

  def self.source_template(source)
    <<~TEMPLATE
    ---
    product_code: #{source.products.code}
    country_id: #{source.countries.id}
    title: #{source.products.name} in #{source.countries.name}
    slug: #{source.products.slug}-#{source.countries.code.downcase}
    ---

    # #{source.products.name}

    Available in #{source.countries.name} (#{source.countries.code}) for $#{source.products.price}.

    Product code: #{source.products.code}
    TEMPLATE
  end
end
