class DataApiProduct
  attr_reader :id, :name, :active

  def initialize(id:, name:, active:)
    @id, @name, @active = id, name, active
  end
end

class DataApiSource
  def self.all
    [
      DataApiProduct.new(id: "product-1", name: "API Product 1", active: true),
      DataApiProduct.new(id: "product-2", name: "API Product 2", active: false)
    ]
  end
end
