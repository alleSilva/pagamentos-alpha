class RejectedCompany < ApplicationRecord
  belongs_to :company

  validates :reason, presence: true
  validates :reason, length: { minimum: 10 }
  validates :company_id, uniqueness: { message: 'já rejeitada' }
end
