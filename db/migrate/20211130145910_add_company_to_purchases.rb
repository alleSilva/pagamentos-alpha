class AddCompanyToPurchases < ActiveRecord::Migration[6.1]
  def change
    add_reference :purchases, :company, null: false, foreign_key: true
  end
end
