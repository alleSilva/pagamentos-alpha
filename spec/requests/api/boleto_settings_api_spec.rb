require 'rails_helper'

describe 'Boleto setting API' do
  context 'GET /api/v1/boleto_settings/:company_token' do
    it 'should get all settings from requesting company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      boleto_setting = create_list(:boleto_setting, 3, company: company)
      boleto_setting[2].payment_method.disabled!
      create_list(:boleto_setting, 2, company: other_company)

      get '/api/v1/boleto_settings', headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body.first[:boleto_setting][:agency_number]).to eq(boleto_setting.first.agency_number)
      expect(parsed_body.first[:boleto_setting][:account_number]).to eq(boleto_setting.first.account_number)
      expect(parsed_body.first[:boleto_setting][:token]).to eq(boleto_setting.first.token)
      expect(parsed_body.first[:boleto_setting][:bank_code]).to eq(boleto_setting.first.bank_code)
      expect(parsed_body.first[:boleto_setting][:payment_method][:name]).to eq(boleto_setting.first.payment_method.name)
      expect(parsed_body.second[:boleto_setting][:agency_number]).to eq(boleto_setting.second.agency_number)
      expect(parsed_body.second[:boleto_setting][:token]).to eq(boleto_setting.second.token)
      expect(parsed_body.count).to eq(2)
    end

    it 'returns no settings' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      owner2 = create(:user, :complete_company_owner)
      company2 = owner2.company
      company2.accepted!

      create_list(:boleto_setting, 2, company: company2)

      get '/api/v1/boleto_settings', headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body).to be_empty
    end
  end

  context 'GET /api/v1/boleto_settings/:token' do
    it 'should get corresponding setting from requesting company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      boleto_settings = create_list(:boleto_setting, 3, company: company)
      boleto_settings.first.payment_method.disabled!

      get "/api/v1/boleto_settings/#{boleto_settings.first.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body[:boleto_setting][:agency_number]).to eq(boleto_settings.first.agency_number)
      expect(parsed_body[:boleto_setting][:account_number]).to eq(boleto_settings.first.account_number)
      expect(parsed_body[:boleto_setting][:token]).to eq(boleto_settings.first.token)
      expect(parsed_body[:boleto_setting][:bank_code]).to eq(boleto_settings.first.bank_code)
      expect(parsed_body[:boleto_setting][:payment_method][:status]).to eq(boleto_settings.first.payment_method.status)
      expect(parsed_body[:boleto_setting][:payment_method][:name]).to eq(boleto_settings.first.payment_method.name)
    end

    it 'should return 404 if setting does not exist' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      get '/api/v1/boleto_settings/999', headers: { companyToken: company.token }

      expect(response).to have_http_status(404)
    end

    it 'should return 401 if setting is from another company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      other_boleto_setting = create(:boleto_setting, company: other_company)

      get "/api/v1/boleto_settings/#{other_boleto_setting.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(401)
    end

    it 'should return 500 if database is not available' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      boleto_setting = create(:boleto_setting, company: company)

      allow(BoletoSetting).to receive(:find_by).and_raise(ActiveRecord::ActiveRecordError)

      get "/api/v1/boleto_settings/#{boleto_setting.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(500)
    end
  end
end
