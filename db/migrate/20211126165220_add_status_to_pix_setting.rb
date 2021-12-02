class AddStatusToPixSetting < ActiveRecord::Migration[6.1]
  def change
    add_column :pix_settings, :status, :integer, default: 5
  end
end
