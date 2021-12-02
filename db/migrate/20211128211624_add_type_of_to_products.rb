class AddTypeOfToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :type_of, :integer, default: 0
  end
end
