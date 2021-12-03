require 'rails_helper'

RSpec.describe CustomerSubscription, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  context '.renew_subscriptions' do
    it 'should create purchases for subscriptions in 2021-12-01' do
      date = Date.new(2021, 12, 0o1)
      customer_subscription1 = customer_subscription2 = another_customer_subscription = nil

      travel_to date do
        customer_subscription1, customer_subscription2 = create_list(
          :customer_subscription, 2
        )
      end

      travel_to date + 1.day do
        another_customer_subscription = create(:customer_subscription)
      end

      travel_to date + 1.month do
        CustomerSubscription.renew_subscriptions

        expect(Purchase.count).to eq(2)
        first_purchase = Purchase.first
        second_purchase = Purchase.second
        expect(first_purchase.customer_payment_method.token).to eq(
          customer_subscription1.customer_payment_method.token
        )
        expect(first_purchase.product.token).to eq(customer_subscription1.product.token)
        expect(first_purchase.cost).to eq(customer_subscription1.cost)
        expect(first_purchase.expiration_date.day).to eq(customer_subscription1.renovation_date)
        expect(first_purchase.company.id).to eq(customer_subscription1.company.id)

        expect(second_purchase.customer_payment_method.token).to eq(
          customer_subscription2.customer_payment_method.token
        )
        expect(second_purchase.product.token).to eq(customer_subscription2.product.token)
        expect(second_purchase.cost).to eq(customer_subscription2.cost)
        expect(second_purchase.expiration_date.day).to eq(customer_subscription2.renovation_date)
        expect(second_purchase.company.id).to eq(customer_subscription2.company.id)
      end
    end

    it 'should not create purchase at same day subscription is created' do
      another_customer_subscription = customer_subscription = nil
      date = Date.new(2021, 12, 0o1)

      travel_to date do
        another_customer_subscription = create(:customer_subscription)
      end

      travel_to date + 1.month do
        customer_subscription = create(:customer_subscription)

        CustomerSubscription.renew_subscriptions

        expect(Purchase.count).to eq(1)
        first_purchase = Purchase.first
        expect(first_purchase.customer_payment_method.token).to eq(
          another_customer_subscription.customer_payment_method.token
        )
        expect(first_purchase.product.token).to eq(another_customer_subscription.product.token)
        expect(first_purchase.customer_payment_method.token).not_to eq(
          customer_subscription.customer_payment_method.token
        )
        expect(first_purchase.product.token).not_to eq(customer_subscription.product.token)
      end
    end

    it 'should not create purchases for canceled subscriptions' do
      customer_subscription = another_customer_subscription = nil
      date = Date.new(2021, 12, 0o1)

      travel_to date do
        customer_subscription = create(:customer_subscription)
        customer_subscription.canceled!
        another_customer_subscription = create(:customer_subscription)
      end

      travel_to date + 1.month do
        CustomerSubscription.renew_subscriptions

        expect(Purchase.count).to eq(1)
        first_purchase = Purchase.first
        expect(first_purchase.customer_payment_method.token).to eq(
          another_customer_subscription.customer_payment_method.token
        )
        expect(first_purchase.product.token).to eq(another_customer_subscription.product.token)
        expect(first_purchase.customer_payment_method.token).not_to eq(
          customer_subscription.customer_payment_method.token
        )
        expect(first_purchase.product.token).not_to eq(customer_subscription.product.token)
      end
    end

    it 'should create purchases for pending subscriptions at retry date' do
      date = Date.new(2021, 12, 0o1)
      next_renovation = date + 1.month
      customer_subscription = nil

      travel_to date do
        customer_subscription = create(
          :customer_subscription, retry_date: next_renovation + 2.days,
                                  tried_renew_times: 1, status: 'pending'
        )
      end

      travel_to next_renovation + 2.days do
        CustomerSubscription.renew_subscriptions

        expect(Purchase.count).to eq(1)
        first_purchase = Purchase.first
        expect(first_purchase.customer_payment_method.token).to eq(
          customer_subscription.customer_payment_method.token
        )
        expect(first_purchase.product.token).to eq(customer_subscription.product.token)
      end
    end

    # TODO: buscar assinaturas que não geraram cobrança no dia (se o sistema cair, etc)
    it 'should create purchases for subscriptions not renewed in the right day'
  end

  # esse metodo seria chamado pela cobrança (Purchase), quando a cobrança fosse recusada
  context '.retry_purchase_creation' do
    it 'should set retry_date to 2 days later' do
      date = Date.new(2021, 12, 0o1)
      customer_subscription = nil

      travel_to date do
        customer_subscription = create(:customer_subscription)
      end

      travel_to date + 1.month do
        CustomerSubscription.retry_purchase_creation(
          customer_payment_method: customer_subscription.customer_payment_method,
          product: customer_subscription.product
        )

        customer_subscription.reload
        expect(customer_subscription.retry_date).to eq(2.days.from_now)
        expect(customer_subscription.tried_renew_times).to eq(1)
        expect(customer_subscription.status).to eq('pending')
      end
    end

    it 'should set retry_date to 4 days later' do
      date = Date.new(2021, 12, 0o1)
      next_renovation = date + 1.month
      customer_subscription = nil

      travel_to date do
        customer_subscription = create(
          :customer_subscription, retry_date: next_renovation + 2.days,
                                  tried_renew_times: 1, status: 'pending'
        )
      end

      travel_to next_renovation + 2.days do
        CustomerSubscription.retry_purchase_creation(
          customer_payment_method: customer_subscription.customer_payment_method,
          product: customer_subscription.product
        )

        customer_subscription.reload
        expect(customer_subscription.retry_date).to eq(next_renovation + 4.days)
        expect(customer_subscription.tried_renew_times).to eq(2)
        expect(customer_subscription.status).to eq('pending')
      end
    end

    it 'should cancel subscription after 5 days' do
      date = Date.new(2021, 12, 0o1)
      next_renovation = date + 1.month
      customer_subscription = nil

      travel_to date do
        customer_subscription = create(
          :customer_subscription, retry_date: next_renovation + 4.days,
                                  tried_renew_times: 2, status: 'pending'
        )
      end

      travel_to next_renovation + 4.days do
        CustomerSubscription.retry_purchase_creation(
          customer_payment_method: customer_subscription.customer_payment_method,
          product: customer_subscription.product
        )

        customer_subscription.reload
        expect(customer_subscription.retry_date).to eq(next_renovation + 4.days)
        expect(customer_subscription.tried_renew_times).to eq(3)
        expect(customer_subscription.status).to eq('canceled')
      end
    end
  end

  # PoF, PULAR PRA NÃO ATRAPALHAR O FLUXO NORMAL DOS TESTES
  context 'scheduler' do
    xit 'should automatically create purchases' do
      customer_subscription1 = customer_subscription2 = nil

      travel_to Date.new(2021, 12, 0o1) do
        customer_subscription1, customer_subscription2 = create_list(:customer_subscription, 2)
      end

      travel_to Date.new(2022, 0o1, 0o1) do
        sleep 1         # isso espera o rufus-scheduler rodar antes que o teste acabe

        expect(Purchase.count).to eq(2)
        first_purchase = Purchase.first
        second_purchase = Purchase.second
        expect(first_purchase.customer_payment_method.token).to eq(
          customer_subscription1.customer_payment_method.token
        )
        expect(first_purchase.product.token).to eq(customer_subscription1.product.token)
        expect(first_purchase.cost).to eq(customer_subscription1.cost)
        expect(first_purchase.expiration_date.day).to eq(customer_subscription1.renovation_date)
        expect(first_purchase.company.id).to eq(customer_subscription1.company.id)

        expect(second_purchase.customer_payment_method.token).to eq(
          customer_subscription2.customer_payment_method.token
        )
        expect(second_purchase.product.token).to eq(customer_subscription2.product.token)
        expect(second_purchase.cost).to eq(customer_subscription2.cost)
        expect(second_purchase.expiration_date.day).to eq(customer_subscription2.renovation_date)
        expect(second_purchase.company.id).to eq(customer_subscription2.company.id)
      end

      travel_to Date.new(2022, 0o2, 0o1) do
        sleep 1
        expect(Purchase.count).to eq(4)
      end
    end
  end
end
