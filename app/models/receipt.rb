class Receipt < ApplicationRecord
  belongs_to :purchase, optional: true

  after_create :generate_token_attribute
end
