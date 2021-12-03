class Fraud < ApplicationRecord
  belongs_to :purchase

  has_one_attached :file

  validates :title, presence: true, length: { minimum: 5 }
  validates :description, length: { minimum: 15 }
  validates :purchase_id, uniqueness: { message: 'já avaliada' }
end
