class AddRetryDateAndTriedRenewTimesToCustomerSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :customer_subscriptions, :retry_date, :date
    add_column :customer_subscriptions, :tried_renew_times, :integer, default: 0
  end
end
