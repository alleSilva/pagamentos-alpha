require 'rails_helper'

describe 'Customer subscription API' do
  context 'GET /api/v1/customer_subscriptions' do
    it 'successfully' do
      customer_subscription = create(:customer_subscription)
      company = customer_subscription.company

      customer_subscriptions = create_list(:customer_subscription, 3, company: company)
      customer_subscriptions = [customer_subscription] + customer_subscriptions

      get '/api/v1/customer_subscriptions', headers: { companyToken: company.token }

      customer_subscriptions.each.with_index do |customer_sub, position|
        parsed_customer_subscription = parsed_body[position][:customer_subscription]
        expect(parsed_customer_subscription[:renovation_date]).to eq(customer_sub.renovation_date)
        expect(parsed_customer_subscription[:token]).to eq(customer_sub.token)
        expect(parsed_customer_subscription[:status]).to eq(customer_sub.status)
        expect(parsed_customer_subscription[:cost]).to eq(customer_sub.cost.to_s)
        expect(parsed_customer_subscription[:product][:name]).to eq(customer_sub.product.name)
        expect(parsed_customer_subscription[:product][:type_of]).to eq(customer_sub.product.type_of)
        expect(parsed_customer_subscription[:product][:token]).to eq(customer_sub.product.token)
      end
    end
  end

  context 'GET /api/v1/customer_subscriptions/:token' do
    it 'should get corresponding setting from requesting company' do
      customer_subscription = create(:customer_subscription)
      company = customer_subscription.company

      get "/api/v1/customer_subscriptions/#{customer_subscription.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      parsed_customer_subscription = parsed_body[:customer_subscription]
      expect(parsed_customer_subscription[:renovation_date]).to eq(customer_subscription.renovation_date)
      expect(parsed_customer_subscription[:token]).to eq(customer_subscription.token)
      expect(parsed_customer_subscription[:status]).to eq(customer_subscription.status)
      expect(parsed_customer_subscription[:cost]).to eq(customer_subscription.cost.to_s)
      expect(parsed_customer_subscription[:product][:name]).to eq(customer_subscription.product.name)
      expect(parsed_customer_subscription[:product][:type_of]).to eq(customer_subscription.product.type_of)
      expect(parsed_customer_subscription[:product][:token]).to eq(customer_subscription.product.token)
    end

    it 'should return 404 if setting does not exist' do
      customer_subscription = create(:customer_subscription)
      company = customer_subscription.company

      get '/api/v1/customer_subscriptions/999', headers: { companyToken: company.token }

      expect(response).to have_http_status(404)
    end

    it 'should return 500 if database is not available' do
      customer_subscription = create(:customer_subscription)
      company = customer_subscription.company

      allow(CustomerSubscription).to receive(:find_by).and_raise(ActiveRecord::ActiveRecordError)

      get "/api/v1/customer_subscriptions/#{customer_subscription.id}", headers: { companyToken: company.token }

      expect(response).to have_http_status(500)
    end
  end
end
