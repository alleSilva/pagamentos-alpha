require 'rails_helper'

describe 'administrator enable a payment method' do
  it 'must be signed in' do
    visit new_admin_payment_method_path

    expect(page).to have_content('Faça login para ter acesso ao sistema')
  end

  it 'successfully' do
    admin = create(:admin)
    admin.confirm
    payment_method = create(:payment_method)
    payment_method.disabled!
    login_as admin, scope: :admin
    visit root_path

    click_on 'Listar todos'
    click_on payment_method.name
    click_on 'Habilitar'

    expect(page).to have_content('Nome: Cartão de Crédito Visa')
    expect(page).to have_content('Taxa (%): 5.0')
    expect(page).to have_content('Taxa máxima: R$ 50,00')
    expect(page).to have_content('Status: Habilitado')
    expect(page).to have_link('Desabilitar')
  end
end
