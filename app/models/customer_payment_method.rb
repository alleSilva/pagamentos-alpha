class PaymentSettingValidator < ActiveModel::Validator
  def validate(record)
    case record.type_of
    when 'pix'
      return unless record.pix_setting.nil?
    when 'boleto'
      return unless record.boleto_setting.nil?
    when 'credit_card'
      return unless record.credit_card_setting.nil?
    end

    record.errors.add :base, 'É obrigatório passar uma payment setting enabled, de acordo com o type_of passado!'
  end
end

class CustomerPaymentMethod < ApplicationRecord
  belongs_to :company
  belongs_to :customer

  belongs_to :pix_setting, optional: true
  belongs_to :boleto_setting, optional: true
  belongs_to :credit_card_setting, optional: true

  after_create :generate_token_attribute

  validates :credit_card_name, :credit_card_number, :credit_card_expiration_date,
            :credit_card_security_code, presence: true, if: -> { credit_card? }

  validate :expiration_date_cannot_be_in_the_past, if: -> { credit_card? }

  validates_with PaymentSettingValidator

  enum type_of: { pix: 5, boleto: 10, credit_card: 15 }

  # TODO: testar esse metodo?
  def add_credit_card(params)
    return unless credit_card?

    self.credit_card_name = params[:credit_card_name]
    self.credit_card_number = params[:credit_card_number]
    self.credit_card_expiration_date = params[:credit_card_expiration_date]
    self.credit_card_security_code = params[:credit_card_security_code]
  end

  private

  def expiration_date_cannot_be_in_the_past
    return unless credit_card_expiration_date.present? && credit_card_expiration_date < Time.zone.today

    errors.add(:credit_card_name, 'inválido(a)')
    errors.add(:credit_card_number, 'inválido(a)')
    errors.add(:credit_card_expiration_date, 'inválido(a)')
    errors.add(:credit_card_security_code, 'inválido(a)')
  end
end
