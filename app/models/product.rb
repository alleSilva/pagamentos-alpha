class Product < ApplicationRecord
  belongs_to :company

  enum status: { enabled: 5, disabled: 10 }
  enum type_of: { single: 0, subscription: 5 }

  validates :name, presence: true

  after_create :generate_token_attribute

  def generate_token_attribute
    self.token = generate_token
    save!
  end

  def self.human_type_of_name(type_of_key)
    Product.human_attribute_name("type_of.#{type_of_key}")
  end

  def self.product_types_dropdown
    type_keys = Product.type_ofs.keys
    dropdown_list = []
    type_keys.each do |type_key|
      dropdown_list << [Product.human_type_of_name(type_key), type_key]
    end

    dropdown_list
  end
end
