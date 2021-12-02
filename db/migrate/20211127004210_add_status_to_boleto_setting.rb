class AddStatusToBoletoSetting < ActiveRecord::Migration[6.1]
  def change
    add_column :boleto_settings, :status, :integer, default: 5
  end
end
