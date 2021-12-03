class CreateReceipts < ActiveRecord::Migration[6.1]
  def change
    create_table :receipts do |t|
      t.references :purchase, null: false, foreign_key: true

      t.timestamps
    end
  end
end
