class CreatePurchases < ActiveRecord::Migration[6.1]
  def change
    create_table :purchases do |t|
      t.string :token
      t.references :customer_payment_method, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :cost
      t.references :receipt, null: true, foreign_key: true
      t.date :paid_date
      t.date :expiration_date

      t.timestamps
    end
  end
end
