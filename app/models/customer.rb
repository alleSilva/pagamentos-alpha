class Customer < ApplicationRecord
  belongs_to :company

  after_create :generate_token_attribute

  validates :name, presence: true, customer_name: true
  validates :cpf, presence: true, cpf_dot: true, length: { is: 11 }
end
