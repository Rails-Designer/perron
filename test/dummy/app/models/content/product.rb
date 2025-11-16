class Content::Product < Perron::Resource
  sources :countries, products: { primary_key: :code }

  def self.source_template(sources)
    <<~TEMPLATE
    ---
    product_code: #{sources.products.code}
    country_id: #{sources.countries.id}
    title: #{sources.products.name} in #{sources.countries.name}
    slug: #{sources.products.slug}-#{sources.countries.code.downcase}
    ---

    # #{sources.products.name}

    Available in #{sources.countries.name} (#{sources.countries.code}) for $#{sources.products.price}.

    Product code: #{sources.products.code}
    TEMPLATE
  end
end
