class AddStatusToPurchase < ActiveRecord::Migration[6.1]
  def change
    add_column :purchases, :status, :integer, default: 0
  end
end
