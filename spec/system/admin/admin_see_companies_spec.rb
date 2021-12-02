require 'rails_helper'

describe 'Admin try to see all companies' do
  it 'sucessfully' do
    user1 = create(:user, :complete_company_owner)
    user2 = create(:user, :complete_company_owner)
    admin = create(:admin)
    admin.confirm

    login_as admin, scope: :admin
    visit root_path
    click_on 'Gerenciar Empresas'

    expect(page).to have_content('Owner')
    expect(page).to have_content('Empresa')
    expect(page).to have_content('Status')
    expect(page).to have_content(user1.email)
    expect(page).to have_content(user2.email)
    expect(page).to have_content(user1.company.legal_name)
    expect(page).to have_content(user2.company.legal_name)
    expect(page).to have_content(Company.human_attribute_name("status.#{user1.company.status}").capitalize)
    expect(page).to have_content(Company.human_attribute_name("status.#{user2.company.status}").capitalize)
  end

  it 'and hasnt did the login' do
    visit companies_path

    expect(current_path).to eq new_admin_session_path
  end

  it 'and see only pending companies' do
    user1 = create(:user, :complete_company_owner)
    user1.company.pending!
    user2 = create(:user, :complete_company_owner)
    user2.company.accepted!
    admin = create(:admin)
    admin.confirm

    login_as admin, scope: :admin
    visit root_path
    click_on 'Gerenciar Empresas'
    click_on 'Empresas Pendentes'

    expect(page).to have_content('Owner')
    expect(page).to have_content('Empresa')
    expect(page).to have_content('Status')
    expect(page).to have_content('Ação')
    expect(page).to have_content(user1.email)
    expect(page).to_not have_content(user2.email)
    expect(page).to have_content(user1.company.legal_name)
    expect(page).to_not have_content(user2.company.legal_name)
    expect(page).to have_content(Company.human_attribute_name("status.#{user1.company.status}").capitalize)
    expect(page).to_not have_content(Company.human_attribute_name("status.#{user2.company.status}").capitalize)
    expect(page).to have_link('Aprovar', count: 1)
    expect(page).to have_link('Rejeitar', count: 1)
  end

  context 'and try to accept a company' do
    it 'sucessfully' do
      user1 = create(:user, :complete_company_owner)
      admin = create(:admin)
      admin.confirm

      login_as admin, scope: :admin
      visit root_path
      click_on 'Gerenciar Empresas'
      click_on 'Empresas Pendentes'
      click_on 'Aprovar'

      expect(page).to have_content('Owner')
      expect(page).to have_content('Empresa')
      expect(page).to have_content('Status')
      expect(page).to have_content('Motivo de Rejeição')
      expect(page).to have_content(user1.email)
      expect(page).to have_content(user1.company.legal_name)
      expect(page).to have_content('Aprovada')
    end
  end

  context 'and try to reject a company' do
    it 'and see the page' do
      user1 = create(:user, :complete_company_owner)
      admin = create(:admin)
      admin.confirm

      login_as admin, scope: :admin
      visit root_path
      click_on 'Gerenciar Empresas'
      click_on 'Empresas Pendentes'
      click_on 'Rejeitar'

      expect(page).to have_content(user1.company.legal_name)
      expect(page).to have_content(user1.email)
      expect(page).to have_content("Descreva o motivo da #{user1.company.legal_name} ser negada")
      expect(page).to have_content(user1.email)
      expect(page).to have_button('Rejeitar Empresa')
    end

    it 'and got sucessfully' do
      user1 = create(:user, :complete_company_owner)
      admin = create(:admin)
      admin.confirm

      login_as admin, scope: :admin
      visit root_path
      click_on 'Gerenciar Empresas'
      click_on 'Empresas Pendentes'
      click_on 'Rejeitar'
      fill_in "Descreva o motivo da #{user1.company.legal_name} ser negada",
              with: 'O nome da empresa é claramente um nome fictício, desta forma só podemos aceitar nomes reais.'
      click_on 'Rejeitar Empresa'

      expect(page).to have_content('Owner')
      expect(page).to have_content('Empresa')
      expect(page).to have_content('Status')
      expect(page).to have_content('Motivo de Rejeição')
      expect(page).to have_content(user1.email)
      expect(page).to have_content(user1.company.legal_name)
      expect(page).to have_content('Rejeitada')
      expect(page).to have_content('O nome da empresa é claramente um nome fictício, '\
                                   'desta forma só podemos aceitar nomes reais.')
    end

    it 'and didnt write a message' do
      user1 = create(:user, :complete_company_owner)
      admin = create(:admin)
      admin.confirm

      login_as admin, scope: :admin
      visit root_path
      click_on 'Gerenciar Empresas'
      click_on 'Empresas Pendentes'
      click_on 'Rejeitar'
      fill_in "Descreva o motivo da #{user1.company.legal_name} ser negada", with: ''
      click_on 'Rejeitar Empresa'

      expect(page).to have_content('Motivo não pode ficar em branco')
    end

    it 'and didnt write a short message' do
      user1 = create(:user, :complete_company_owner)
      admin = create(:admin)
      admin.confirm

      login_as admin, scope: :admin
      visit root_path
      click_on 'Gerenciar Empresas'
      click_on 'Empresas Pendentes'
      click_on 'Rejeitar'
      fill_in "Descreva o motivo da #{user1.company.legal_name} ser negada", with: 'Não sei'
      click_on 'Rejeitar Empresa'

      expect(page).to have_content('Motivo é muito curto (mínimo: 10 caracteres)')
    end

    it 'and try to register another reason' do
      user1 = create(:user, :complete_company_owner)
      admin = create(:admin)
      admin.confirm
      RejectedCompany.create!({ company: user1.company,
                                reason: 'Não se enquadra a nossas políticas' })
      user1.company.rejected!

      login_as admin, scope: :admin
      visit new_company_rejected_company_path(user1.company)

      expect(page).to have_content('Empresa já rejeitada')
    end
  end
end
