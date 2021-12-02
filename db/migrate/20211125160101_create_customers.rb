class CreateCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :cpf
      t.string :token
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
