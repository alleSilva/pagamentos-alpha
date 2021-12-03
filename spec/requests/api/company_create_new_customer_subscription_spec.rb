require 'rails_helper'

describe 'Customer subscription API' do
  include ActiveSupport::Testing::TimeHelpers

  context 'POST /api/v1/customer_subscriptions' do
    it 'successfully create' do
      customer_payment_method = create(:customer_payment_method, :pix)
      company = customer_payment_method.company
      subscription = create(:product, type_of: 'subscription', company: company)

      allow(SecureRandom).to receive(:alphanumeric).with(20).and_return('tv4H50dkTdePTNSmMFBl')

      travel_to Date.new(2021, 11, 27) do
        post '/api/v1/customer_subscriptions',
             params: {
               customer_subscription: {
                 customer_payment_method_token: customer_payment_method.token,
                 subscription_token: subscription.token,
                 cost: 9.99
               }
             },
             headers: { companyToken: company.token }

        CustomerSubscription.last

        expect(response).to have_http_status(201)
        customer_subscription = parsed_body[:customer_subscription]
        expect(customer_subscription[:token]).to eq('tv4H50dkTdePTNSmMFBl')
        expect(customer_subscription[:cost]).to eq('9.99')
        expect(customer_subscription[:status]).to eq('active')
        expect(customer_subscription[:renovation_date]).to eq(27)
        expect(customer_subscription[:product][:name]).to eq(subscription.name)
        expect(customer_subscription[:product][:type_of]).to eq('subscription')
        expect(customer_subscription[:product][:token]).to eq(subscription.token)
        expect(customer_subscription[:customer_payment_method][:token]).to eq(customer_payment_method.token)
        expect(customer_subscription[:company][:legal_name]).to eq(company.legal_name)
      end
    end

    it 'fails on passing single type product' do
      customer_payment_method = create(:customer_payment_method, :pix)
      company = customer_payment_method.company
      single_product = create(:product, type_of: 'single', company: company)

      allow(SecureRandom).to receive(:alphanumeric).with(20).and_return('tv4H50dkTdePTNSmMFBl')

      travel_to Date.new(2021, 11, 27) do
        post '/api/v1/customer_subscriptions',
             params: {
               customer_subscription: {
                 customer_payment_method_token: customer_payment_method.token,
                 subscription_token: single_product.token,
                 cost: '32.90'
               }
             },
             headers: { companyToken: company.token }

        expect(response).to have_http_status(422)
        customer_subscription = parsed_body[:request][:customer_subscription]
        errors = parsed_body[:errors]
        expect(errors[:product]).to eq(['sua assinatura precisa ser vinculada com um product do tipo subscription'])

        expect(customer_subscription[:token]).to eq(nil)
        expect(customer_subscription[:cost]).to eq('32.9')
        expect(customer_subscription[:status]).to eq('active')
        expect(customer_subscription[:company][:legal_name]).to eq(company.legal_name)
      end
    end

    it 'fails on passing invalid tokens' do
      customer_payment_method = create(:customer_payment_method, :pix)
      company = customer_payment_method.company
      create(:product, type_of: 'subscription', company: company)

      allow(SecureRandom).to receive(:alphanumeric).with(20).and_return('tv4H50dkTdePTNSmMFBl')

      travel_to Date.new(2021, 11, 27) do
        post '/api/v1/customer_subscriptions',
             params: {
               customer_subscription: {
                 customer_payment_method_token: 'abobrinha',
                 subscription_token: 'batata',
                 cost: ''
               }
             },
             headers: { companyToken: company.token }

        expect(response).to have_http_status(422)
        customer_subscription = parsed_body[:request][:customer_subscription]
        errors = parsed_body[:errors]
        expect(errors[:product]).to eq(['é obrigatório(a)'])
        expect(errors[:customer_payment_method]).to eq(['é obrigatório(a)'])
        expect(errors[:cost]).to eq(['não pode ficar em branco', 'não é um número'])

        expect(customer_subscription[:token]).to eq(nil)
        expect(customer_subscription[:cost]).to eq(nil)
        expect(customer_subscription[:status]).to eq('active')
        expect(customer_subscription[:renovation_date]).to eq(27)
        expect(customer_subscription[:company][:legal_name]).to eq(company.legal_name)
      end
    end

    it 'change date after 28 to 01' do
      customer_payment_method = create(:customer_payment_method, :pix)
      company = customer_payment_method.company
      subscription = create(:product, type_of: 'subscription', company: company)

      allow(SecureRandom).to receive(:alphanumeric).with(20).and_return('tv4H50dkTdePTNSmMFBl')

      travel_to Date.new(2021, 11, 29) do
        post '/api/v1/customer_subscriptions',
             params: {
               customer_subscription: {
                 customer_payment_method_token: customer_payment_method.token,
                 subscription_token: subscription.token,
                 cost: 9.99
               }
             },
             headers: { companyToken: company.token }

        CustomerSubscription.last

        expect(response).to have_http_status(201)
        customer_subscription = parsed_body[:customer_subscription]
        expect(customer_subscription[:token]).to eq('tv4H50dkTdePTNSmMFBl')
        expect(customer_subscription[:cost]).to eq('9.99')
        expect(customer_subscription[:status]).to eq('active')
        expect(customer_subscription[:renovation_date]).to eq(0o1)
        expect(customer_subscription[:product][:name]).to eq(subscription.name)
        expect(customer_subscription[:product][:type_of]).to eq('subscription')
        expect(customer_subscription[:product][:token]).to eq(subscription.token)
        expect(customer_subscription[:customer_payment_method][:token]).to eq(customer_payment_method.token)
        expect(customer_subscription[:company][:legal_name]).to eq(company.legal_name)
      end
    end
  end
end
