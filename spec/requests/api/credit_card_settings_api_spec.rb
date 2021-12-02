require 'rails_helper'

describe 'Credit Card setting API' do
  context 'GET /api/v1/credit_card_settings' do
    it 'should get all settings from requesting company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      credit_card_settings = create_list(:credit_card_setting, 3, company: company)
      credit_card_settings[2].payment_method.disabled!
      first_cc = credit_card_settings[0]
      second_cc = credit_card_settings[1]
      create_list(:credit_card_setting, 2, company: other_company)

      get '/api/v1/credit_card_settings', headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body.first[:credit_card_setting][:company_code]).to eq(first_cc.company_code)
      expect(parsed_body.first[:credit_card_setting][:token]).to eq(first_cc.token)
      expect(parsed_body.first[:credit_card_setting][:payment_method][:name]).to eq(first_cc.payment_method.name)
      expect(parsed_body.second[:credit_card_setting][:company_code]).to eq(second_cc.company_code)
      expect(parsed_body.second[:credit_card_setting][:token]).to eq(second_cc.token)
      expect(parsed_body.count).to eq(2)
    end

    it 'returns no settings' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      owner2 = create(:user, :complete_company_owner)
      company2 = owner2.company
      company2.accepted!

      create_list(:credit_card_setting, 2, company: company2)

      get '/api/v1/credit_card_settings', headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body).to be_empty
    end
  end

  context 'GET /api/v1/credit_card_settings/:token' do
    it 'should get corresponding setting from requesting company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      cc_settings = create_list(:credit_card_setting, 3, company: company)
      cc_settings.first.payment_method.disabled!

      get "/api/v1/credit_card_settings/#{cc_settings.first.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(200)
      expect(parsed_body[:credit_card_setting][:company_code]).to eq(cc_settings.first.company_code)
      expect(parsed_body[:credit_card_setting][:token]).to eq(cc_settings.first.token)
      expect(parsed_body[:credit_card_setting][:payment_method][:status]).to eq(cc_settings.first.payment_method.status)
      expect(parsed_body[:credit_card_setting][:payment_method][:name]).to eq(cc_settings.first.payment_method.name)
    end

    it 'should return 404 if setting does not exist' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      get '/api/v1/credit_card_settings/999', headers: { companyToken: company.token }

      expect(response).to have_http_status(404)
    end

    it 'should return 401 if setting is from another company' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      other_owner = create(:user, :complete_company_owner)
      other_company = other_owner.company
      other_company.accepted!

      other_credit_card_setting = create(:credit_card_setting, company: other_company)

      get "/api/v1/credit_card_settings/#{other_credit_card_setting.token}", headers: { companyToken: company.token }

      expect(response).to have_http_status(401)
    end

    it 'should return 500 if database is not available' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!

      credit_card_setting = create(:credit_card_setting, company: company)

      allow(CreditCardSetting).to receive(:find_by).and_raise(ActiveRecord::ActiveRecordError)

      get "/api/v1/credit_card_settings/#{credit_card_setting.id}", headers: { companyToken: company.token }

      expect(response).to have_http_status(500)
    end
  end
end
