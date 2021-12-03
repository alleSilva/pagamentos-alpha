class CreateCustomerSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :customer_subscriptions do |t|
      t.string :token
      t.integer :status, default: 0
      t.decimal :cost
      t.integer :renovation_date, default: 1
      t.references :product, null: false, foreign_key: true
      t.references :customer_payment_method, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
    add_index :customer_subscriptions, :token, unique: true
  end
end
