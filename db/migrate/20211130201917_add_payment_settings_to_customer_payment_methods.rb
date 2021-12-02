class AddPaymentSettingsToCustomerPaymentMethods < ActiveRecord::Migration[6.1]
  def change
    add_reference :customer_payment_methods, :pix_setting, null: true, foreign_key: true
    add_reference :customer_payment_methods, :boleto_setting, null: true, foreign_key: true
    add_reference :customer_payment_methods, :credit_card_setting, null: true, foreign_key: true
  end
end
