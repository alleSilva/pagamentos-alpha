class PaymentMethod < ApplicationRecord
  has_many :pix_settings, dependent: :destroy
  has_many :credit_card_settings, dependent: :destroy
  has_many :boleto_settings, dependent: :destroy

  has_one_attached :icon
  enum status: { enabled: 5, disabled: 10 }
  enum type_of: { pix: 0, boleto: 5, credit_card: 10 }

  validates :name, :fee, :maximum_fee, :icon, :type_of, presence: true
  validates :type_of, inclusion: { in: type_ofs.keys }

  def self.query_for_enabled
    PaymentMethod.where(status: :enabled)
  end

  def self.human_type_of_name(type_of_key)
    PaymentMethod.human_attribute_name("type_of.#{type_of_key}")
  end

  def self.types
    PaymentMethod.type_ofs.keys
  end

  def self.payment_types_dropdown
    type_keys = PaymentMethod.type_ofs.keys
    dropdown_list = []
    type_keys.each do |type_key|
      dropdown_list << [PaymentMethod.human_type_of_name(type_key), type_key]
    end

    dropdown_list
  end

  def self.payment_methods_by_type_dropdown(payment_type)
    payment_methods = PaymentMethod.where(type_of: payment_type, status: 'enabled')
    dropdown_list = []
    payment_methods.each do |payment_method|
      dropdown_list << [payment_method.name, payment_method.id]
    end

    dropdown_list
  end
end
