require 'rails_helper'

describe 'Pix setting API' do
  context 'GET /api/v1/pix_settings' do
    it 'should get all settings from requesting company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      pix_settings = create_list(:pix_setting, 3, company: company)
      pix_settings[2].payment_method.disabled!
      create_list(:pix_setting, 2, company: other_company)

      get '/api/v1/pix_settings', headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body.first[:pix_setting][:pix_key]).to eq(pix_settings.first.pix_key)
      expect(parsed_body.first[:pix_setting][:token]).to eq(pix_settings.first.token)
      expect(parsed_body.first[:pix_setting][:bank_code]).to eq(pix_settings.first.bank_code)
      expect(parsed_body.first[:pix_setting][:payment_method][:name]).to eq(pix_settings.first.payment_method.name)
      expect(parsed_body.second[:pix_setting][:pix_key]).to eq(pix_settings.second.pix_key)
      expect(parsed_body.second[:pix_setting][:token]).to eq(pix_settings.second.token)
      expect(parsed_body.count).to eq(2)
    end

    it 'returns no settings' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      owner2 = create(:user, :complete_company_owner)
      company2 = owner2.company
      company2.accepted!

      create_list(:pix_setting, 2, company: company2)

      get '/api/v1/pix_settings', headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body).to be_empty
    end
  end

  context 'GET /api/v1/pix_settings/:token' do
    it 'should get corresponding setting from requesting company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      pix_settings = create_list(:pix_setting, 3, company: company)
      pix_settings.first.payment_method.disabled!

      get "/api/v1/pix_settings/#{pix_settings.first.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body[:pix_setting][:pix_key]).to eq(pix_settings.first.pix_key)
      expect(parsed_body[:pix_setting][:token]).to eq(pix_settings.first.token)
      expect(parsed_body[:pix_setting][:bank_code]).to eq(pix_settings.first.bank_code)
      expect(parsed_body[:pix_setting][:payment_method][:status]).to eq(pix_settings.first.payment_method.status)
      expect(parsed_body[:pix_setting][:payment_method][:name]).to eq(pix_settings.first.payment_method.name)
    end

    it 'should return 404 if setting does not exist' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      get '/api/v1/pix_settings/999', headers: { companyToken: company.token }

      expect(response).to have_http_status(404)
    end

    it 'should return 401 if setting is from another company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      other_pix_setting = create(:pix_setting, company: other_company)

      get "/api/v1/pix_settings/#{other_pix_setting.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(401)
    end

    it 'should return 500 if database is not available' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      pix_setting = create(:pix_setting, company: company)

      allow(PixSetting).to receive(:find_by).and_raise(ActiveRecord::ActiveRecordError)

      get "/api/v1/pix_settings/#{pix_setting.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(500)
    end
  end
end
