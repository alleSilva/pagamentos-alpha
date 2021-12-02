require 'rails_helper'

describe 'Owner creates boleto payment setting' do
  it 'successfully' do
    owner = create(:user, :complete_company_owner)
    company = owner.company
    company.accepted!

    boleto_method, * = create_list(:payment_method, 3, :boleto)

    login_as owner, scope: :user
    visit company_path owner.company
    click_on 'Meios de pagamento configurados'
    click_on 'Configurar novo boleto'

    fill_in 'Número da conta', with: '317283472634723'
    fill_in 'Número da agência', with: '21321312421412'
    fill_in 'Código do banco', with: '001'
    select boleto_method.name, from: 'Meio de pagamento'
    click_on 'Criar Pagamento por boleto'

    expect(current_path).to eq(company_payment_settings_path(owner.company))
    expect(page).to have_content('Pagamento configurado com sucesso')
    expect(page).to have_content('Número da conta: 317283472634723')
    expect(page).to have_content('Número da agência: 21321312421412')
    expect(page).to have_content('Código do banco: 001')
    expect(owner.company.payment_settings).to include(BoletoSetting.first)
  end

  it 'fails on leaving everything empty' do
    owner = create(:user, :complete_company_owner)
    company = owner.company
    company.accepted!

    create_list(:payment_method, 3, :boleto)

    login_as owner, scope: :user
    visit company_path owner.company
    click_on 'Meios de pagamento configurados'
    click_on 'Configurar novo boleto'
    click_on 'Criar Pagamento por boleto'

    expect(page).to have_content('não pode ficar em branco')
  end
end
