require 'rails_helper'

describe 'Receipt Api' do
  context 'GET /api/v1/receipts' do
    it 'company should view all company receipts' do
      receipt = create(:receipt)
      create(:receipt)
      company = receipt.purchase.company

      get '/api/v1/receipts/', headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      purchase = parsed_body.first[:receipt][:purchase]
      expect(parsed_body.first[:receipt][:token]).to eq(receipt.token)
      expect(parsed_body.first[:receipt][:authorization_code]).not_to be_nil
      expect(purchase[:customer_payment_method][:type_of]).to eq(
        receipt.purchase.customer_payment_method.type_of
      )
      expect(purchase[:paid_date]).to eq(receipt.purchase.paid_date.to_s)
      expect(purchase[:expiration_date]).to eq(receipt.purchase.expiration_date.to_s)
      expect(purchase[:product][:name]).to eq(receipt.purchase.product.name)
      expect(purchase[:product][:token]).to eq(receipt.purchase.product.token)
      expect(purchase[:company][:legal_name]).to eq(receipt.purchase.company.legal_name)

      expect(parsed_body.second).to be_nil
    end

    it 'and receive empty response' do
      owner = create(:user, :complete_company_owner)
      owner.company.accepted!

      get '/api/v1/receipts/', headers: { companyToken: owner.company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body).to be_empty
    end

    it '401 unauthorized' do
      create(:receipt)

      get '/api/v1/receipts/', headers: { companyToken: 'notacompanytoken' }

      expect(response).to have_http_status(401)
      expect(parsed_body[:message]).to eq('Há algo errado com sua autenticação.')
    end

    it '500 server error' do
      receipt = create(:receipt)
      company = receipt.purchase.company

      allow(Receipt).to receive(:where).and_raise(ActiveRecord::ActiveRecordError)
      get '/api/v1/receipts/', headers: { companyToken: company.token }

      expect(response).to have_http_status(500)
      expect(parsed_body[:message]).to eq('Erro geral')
    end
  end

  context 'GET /api/v1/receipt/:id' do
    it 'visitor should view one receipt' do
      receipt = create(:receipt)
      create(:receipt)

      get "/api/v1/receipts/#{receipt[:token]}"

      expect(response).to have_http_status(200)
      purchase = parsed_body[:receipt][:purchase]
      expect(parsed_body[:receipt][:token]).to eq(receipt.token)
      expect(parsed_body[:receipt][:authorization_code]).not_to be_nil
      expect(purchase[:customer_payment_method][:type_of]).to eq(
        receipt.purchase.customer_payment_method.type_of
      )
      expect(purchase[:paid_date]).to eq(receipt.purchase.paid_date.to_s)
      expect(purchase[:expiration_date]).to eq(receipt.purchase.expiration_date.to_s)
      expect(purchase[:product][:name]).to eq(receipt.purchase.product.name)
      expect(purchase[:product][:token]).to eq(receipt.purchase.product.token)
      expect(purchase[:company][:legal_name]).to eq(receipt.purchase.company.legal_name)
    end

    it '404 not found' do
      get '/api/v1/receipts/uy2387rg23h'

      expect(response).to have_http_status(404)
      expect(parsed_body[:message]).to eq('Objeto não encontrado')
    end

    it '500 server error' do
      receipt = create(:receipt)

      allow(Receipt).to receive(:find_by).and_raise(ActiveRecord::ActiveRecordError)
      get "/api/v1/receipts/#{receipt[:authorization_code]}"

      expect(response).to have_http_status(500)
      expect(parsed_body[:message]).to eq('Erro geral')
    end
  end
end
