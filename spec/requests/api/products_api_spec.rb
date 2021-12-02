require 'rails_helper'

describe 'Product API' do
  context 'POST /api/v1/products' do
    it 'successfully as product' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      post '/api/v1/products',
           params: { product: { name: 'Video de LOL', type_of: 'single' } },
           headers: { companyToken: company.token }

      product = Product.last

      expect(response).to have_http_status(201)
      expect(parsed_body[:product][:name]).to eq(product.name)
      expect(parsed_body[:product][:type_of]).to eq('single')
      expect(parsed_body[:product][:token]).to eq(product.token)
    end

    it 'successfully as subscription' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      post '/api/v1/products',
           params: { product: { name: 'Video de LOL', type_of: 'subscription' } },
           headers: { companyToken: company.token }

      product = Product.last

      expect(response).to have_http_status(201)
      expect(parsed_body[:product][:name]).to eq(product.name)
      expect(parsed_body[:product][:type_of]).to eq('subscription')
      expect(parsed_body[:product][:token]).to eq(product.token)
    end

    it 'fail because name is blank' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      post '/api/v1/products',
           params: { product: { name: '' } },
           headers: { companyToken: company.token }

      expect(response).to have_http_status(422)
      expect(parsed_body[:errors][:name]).to eq(['não pode ficar em branco'])
    end
  end
  context 'GET /api/v1/products' do
    it 'should get all correspondig products' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      products = create_list(:product, 3, company: company)
      products[2].disabled!
      create_list(:product, 2, company: other_company)

      get '/api/v1/products', headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body.first[:product][:name]).to eq(products.first.name)
      expect(parsed_body.first[:product][:token]).to eq(products.first.token)
      expect(parsed_body.second[:product][:name]).to eq(products.second.name)
      expect(parsed_body.second[:product][:token]).to eq(products.second.token)
      expect(parsed_body.count).to eq(2)
    end

    it 'return no product' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      owner2 = create(:user, :complete_company_owner)
      company2 = owner2.company
      company2.accepted!

      create_list(:product, 2, company: company2)

      get '/api/v1/products', headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body).to be_empty
    end
  end
  context 'GET /api/v1/products/:token' do
    it 'should get correspondig product' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      products = create_list(:product, 3, company: company)
      products.first.disabled!

      get "/api/v1/products/#{products.first.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body[:product][:name]).to eq(products.first.name)
      expect(parsed_body[:product][:token]).to eq(products.first.token)
      expect(parsed_body[:product][:status]).to eq(products.first.status)
    end

    it 'should return 404 if product does not exist' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      get '/api/v1/products/hwduhdwuqhdwquhdqi', headers: { companyToken: company.token }

      expect(response).to have_http_status(404)
    end

    it 'should return 401 if setting is from another company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      other_product = create(:product, company: other_company)

      get "/api/v1/products/#{other_product.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(401)
    end
  end

  context 'POST /api/v1/products/:token/disable' do
    it 'successfully' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      product = create(:product, company: company)

      post "/api/v1/products/#{product.token}/disable", headers: { companyToken: company.token }

      expect(response).to have_http_status(204)
      expect(product.reload.status).to eq('disabled')
    end

    it 'should return 404 if product does not exist' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      post '/api/v1/products/hwduhdwuqhdwquhdqi/disable', headers: { companyToken: company.token }

      expect(response).to have_http_status(404)
    end

    it 'should return 401 if setting is from another company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      other_product = create(:product, company: other_company)

      post "/api/v1/products/#{other_product.token}/disable", headers: { companyToken: company.token }

      expect(response).to have_http_status(401)
    end
  end

  context 'POST /api/v1/products/:token/enable' do
    it 'successfully' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      product = create(:product, company: company)
      product.disabled!

      post "/api/v1/products/#{product.token}/enable", headers: { companyToken: company.token }

      expect(response).to have_http_status(204)
      expect(product.reload.status).to eq('enabled')
    end

    it 'should return 404 if product does not exist' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      post '/api/v1/products/hwduhdwuqhdwquhdqi/enable', headers: { companyToken: company.token }

      expect(response).to have_http_status(404)
    end

    it 'should return 401 if setting is from another company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      other_product = create(:product, company: other_company)

      post "/api/v1/products/#{other_product.token}/enable", headers: { companyToken: company.token }

      expect(response).to have_http_status(401)
    end
  end
end
