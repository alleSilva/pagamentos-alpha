require 'rails_helper'

RSpec.describe CustomerSubscription, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  context '.renew_subscriptions' do
    it 'should create purchases for subscriptions in 2021-12-01' do
      customer_subscription_1, customer_subscription_2 = create_list(
        :customer_subscription, 2, renovation_date: '2021-12-01'
      )
      another_customer_subscription = create(:customer_subscription, renovation_date: '2021-12-02')

      travel_to Date.new(2021, 12, 01) do
        CustomerSubscription.renew_subscriptions

        expect(Purchase.count).to eq(2)
        first_purchase = Purchase.first
        second_purchase = Purchase.second
        expect(first_purchase.customer_payment_method.token).to eq(
          customer_subscription_1.customer_payment_method.token
        )
        expect(first_purchase.product.token).to eq(customer_subscription_1.product.token)
        expect(first_purchase.cost).to eq(customer_subscription_1.cost)
        # expiration date deveria ser o mesmo do renovation date?
        expect(first_purchase.expiration_date).to eq(customer_subscription_1.renovation_date)
        expect(first_purchase.company.id).to eq(customer_subscription_1.company.id)

        expect(second_purchase.customer_payment_method.token).to eq(
          customer_subscription_2.customer_payment_method.token
        )
        expect(second_purchase.product.token).to eq(customer_subscription_2.product.token)
        expect(second_purchase.cost).to eq(customer_subscription_2.cost)
        expect(second_purchase.expiration_date).to eq(customer_subscription_2.renovation_date)
        expect(second_purchase.company.id).to eq(customer_subscription_2.company.id)
      end
    end

    it 'should only create purchases for active subscriptions'

    it 'should create purchases for subscriptions not renewed in the right day'
  end

  # TODO: usar rufus-scheduler, MAS PULAR TESTES DEPOIS DO PROOF OF CONCEPT
  context 'scheduler' do
    it 'should automatically create purchases every day'
  end
end
