require 'rails_helper'

describe 'User changes payment settings statuses' do
  context 'pix_setting' do
    it 'can be disabled' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!
      pix_setting = create(:pix_setting, company: company)

      login_as owner, scope: :user
      visit company_payment_settings_path company

      within("##{pix_setting.token}") do
        click_on 'Desabilitar'
      end

      expect(page).to have_content('Desabilitado')
    end

    it 'can be enabled' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!
      pix_setting = create(:pix_setting, company: company)
      pix_setting.disabled!

      login_as owner, scope: :user
      visit company_payment_settings_path company

      within("##{pix_setting.token}") do
        click_on 'Habilitar'
      end

      expect(page).to have_content('Habilitado')
    end
  end

  context 'boleto_setting' do
    it 'can be disabled' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!
      boleto_setting = create(:boleto_setting, company: company)

      login_as owner, scope: :user
      visit company_payment_settings_path company

      within("##{boleto_setting.token}") do
        click_on 'Desabilitar'
      end

      expect(page).to have_content('Desabilitado')
    end

    it 'can be enabled' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!
      boleto_setting = create(:boleto_setting, company: company)
      boleto_setting.disabled!

      login_as owner, scope: :user
      visit company_payment_settings_path company

      within("##{boleto_setting.token}") do
        click_on 'Habilitar'
      end

      expect(page).to have_content('Habilitado')
    end
  end

  context 'credit_card_setting' do
    it 'can be disabled' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!
      credit_card_setting = create(:credit_card_setting, company: company)

      login_as owner, scope: :user
      visit company_payment_settings_path company

      within("##{credit_card_setting.token}") do
        click_on 'Desabilitar'
      end

      expect(page).to have_content('Desabilitado')
    end

    it 'can be enabled' do
      owner = create(:user, :complete_company_owner)
      company = owner.company
      company.accepted!
      credit_card_setting = create(:credit_card_setting, company: company)
      credit_card_setting.disabled!

      login_as owner, scope: :user
      visit company_payment_settings_path company

      within("##{credit_card_setting.token}") do
        click_on 'Habilitar'
      end

      expect(page).to have_content('Habilitado')
    end
  end
end
