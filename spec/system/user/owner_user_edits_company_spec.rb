require 'rails_helper'

describe 'Owner edits company' do
  it 'successfully if accepted' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    login_as owner, scope: :user
    visit company_path(owner.company)
    click_on 'Editar dados'

    fill_in 'Razão social', with: 'Empresa numero 2 editado'
    fill_in 'Endereço de faturamento', with: 'Endereço cidade tal rua tal etc editado'
    fill_in 'E-mail de faturamento', with: 'faturamento@companymaileditado.com'
    fill_in 'CNPJ', with: '12.123.123/0001-13'
    click_on 'Enviar'

    expect(current_path).to eq(company_path(owner.company))
    expect(page).to have_content('Estado de aprovação: aprovada')
    expect(page).to have_content('Razão social: Empresa numero 2 editado')
    expect(page).to have_content('Endereço de faturamento: Endereço cidade tal rua tal etc editado')
    expect(page).to have_content('E-mail de faturamento: faturamento@companymaileditado.com')
    expect(page).to have_content('CNPJ: 12.123.123/0001-13')
  end

  it 'but fails if pending' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    login_as owner, scope: :user
    visit company_path(owner.company)
    expect(page).not_to have_link('Editar dados', href: edit_company_path(owner.company))
  end

  it 'succesfully if rejected but company returns to pending state' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.rejected!

    login_as owner, scope: :user
    visit company_path(owner.company)

    click_on 'Editar dados'

    fill_in 'Razão social', with: 'Empresa numero 2 editado'
    fill_in 'Endereço de faturamento', with: 'Endereço cidade tal rua tal etc editado'
    fill_in 'E-mail de faturamento', with: 'faturamento@companymaileditado.com'
    fill_in 'CNPJ', with: '12.123.123/0001-13'
    click_on 'Enviar'

    expect(current_path).to eq(company_path(owner.company))
    expect(page).to have_content('Estado de aprovação: pendente')
    expect(page).to have_content('Razão social: Empresa numero 2 editado')
    expect(page).to have_content('Endereço de faturamento: Endereço cidade tal rua tal etc editado')
    expect(page).to have_content('E-mail de faturamento: faturamento@companymaileditado.com')
    expect(page).to have_content('CNPJ: 12.123.123/0001-13')
  end

  it 'and user from company cannot view edit link' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    user = create(:user, owner: false, company: owner.company)
    user.confirm

    login_as user, scope: :user
    visit company_path(owner.company)

    expect(page).not_to have_link('Editar dados', href: edit_company_path(owner.company))
  end
end
