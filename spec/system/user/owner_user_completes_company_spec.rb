require 'rails_helper'

describe '(owner)User fills in company detail and sees aproval awaiting page' do
  it 'successfully' do
    user = create(:user, owner: true)
    user.confirm

    login_as user, scope: :user
    visit root_path

    fill_in 'Razão social', with: 'Empresa numero 1'
    fill_in 'Endereço de faturamento', with: 'Endereço cidade tal rua tal etc'
    fill_in 'E-mail de faturamento', with: 'faturamento@companymail.com'
    fill_in 'CNPJ', with: '12.123.123/0001-12'
    click_on 'Enviar'

    expect(page).to have_content('Registro feito com sucesso!')
    expect(page).to have_content('Estado de aprovação: pendente')
    expect(page).to have_content('Razão social: Empresa numero 1')
    expect(page).to have_content('CNPJ: 12.123.123/0001-12')
    expect(page).to have_content('Endereço de faturamento: Endereço cidade tal rua tal etc')
    expect(page).to have_content('E-mail de faturamento: faturamento@companymail.com')
  end

  it 'unless cnpj is invalid' do
    user = create(:user, owner: true)
    user.confirm

    login_as user, scope: :user
    visit root_path

    fill_in 'company_legal_name', with: 'Empresa numero 1'
    fill_in 'company_billing_address', with: 'Endereço cidade tal rua tal etc'
    fill_in 'company_billing_email', with: 'faturamento@companymail.com'
    fill_in 'company_cnpj', with: 'batatinha'
    click_on 'Enviar'

    expect(page).to have_content('CNPJ inválido')
  end

  it 'unless email domain is public' do
    user = create(:user, owner: true)
    user.confirm

    login_as user, scope: :user
    visit root_path

    fill_in 'company_legal_name', with: 'Empresa numero 1'
    fill_in 'company_billing_address', with: 'Endereço cidade tal rua tal etc'
    fill_in 'company_billing_email', with: 'faturamento@gmail.com'
    fill_in 'company_cnpj', with: '12.123.123/0001-12'
    click_on 'Enviar'

    expect(page).to have_content('E-mail de faturamento não pode ser um email de domínio público')
  end

  it 'there are blank fields' do
    user = create(:user, owner: true)
    user.confirm

    login_as user, scope: :user
    visit root_path
    click_on 'Enviar'

    expect(page).to have_content('não pode ficar em branco', count: 4)
  end
end
