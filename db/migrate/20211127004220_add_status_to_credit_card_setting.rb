class AddStatusToCreditCardSetting < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_card_settings, :status, :integer, default: 5
  end
end
