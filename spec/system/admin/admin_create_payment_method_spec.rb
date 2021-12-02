require 'rails_helper'

describe 'administrator creates a new payment method' do
  it 'must be signed in' do
    visit new_admin_payment_method_path

    expect(page).to have_content('Faça login para ter acesso ao sistema')
  end

  it 'credit card successfully' do
    admin = create(:admin)
    admin.confirm

    login_as admin, scope: :admin
    visit root_path

    click_on 'Criar novo'

    fill_in 'Nome', with: 'Cartão de Crédito Visa'
    attach_file 'Ícone', 'app/assets/images/icone_visa.jpg'
    fill_in 'Taxa', with: 5.0
    fill_in 'Taxa máxima', with: 1000.0

    select 'Cartão de crédito', from: 'payment_method_type_of'

    click_on 'Salvar'

    expect(page).to have_content('Nome: Cartão de Crédito Visa')
    expect(page).to have_content('Tipo: Cartão de crédito')
    expect(page).to have_content('Taxa (%): 5.0')
    expect(page).to have_content('Taxa máxima: R$ 1.000,00')
  end

  it 'no successfully when fields are blank' do
    admin = create(:admin)
    admin.confirm

    login_as admin, scope: :admin
    visit root_path

    click_on 'Criar novo'

    click_on 'Salvar'

    expect(page).not_to have_content('Método de pagamento criado com sucesso!')
  end
end
