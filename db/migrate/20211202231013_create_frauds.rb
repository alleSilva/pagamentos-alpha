class CreateFrauds < ActiveRecord::Migration[6.1]
  def change
    create_table :frauds do |t|
      t.string :title
      t.text :description
      t.references :purchase, null: false, foreign_key: true, dependent: :destroy, index: {unique: true}

      t.timestamps
    end
  end
end
