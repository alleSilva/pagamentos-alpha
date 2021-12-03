class AddAuthorizationCodeAndTokenToReceipt < ActiveRecord::Migration[6.1]
  def change
    add_column :receipts, :authorization_code, :string, unique: true
    add_column :receipts, :token, :string, unique: true
  end
end
