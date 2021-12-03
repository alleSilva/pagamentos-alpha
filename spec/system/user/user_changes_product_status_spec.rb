require 'rails_helper'

describe 'User changes products status' do
  it 'to disabled successfully' do
    user = create(:user, :complete_company_owner)
    user.confirm
    user.company.accepted!
    product = create(:product, company: user.company)

    login_as user, scope: :user
    visit product_path(product)
    click_on 'Desabilitar'

    expect(page).to have_content('Desabilitado')
    expect(page).not_to have_content('Habilitado')
    expect(product.reload.status).to eq 'disabled'
  end

  it 'to enabled successfully' do
    user = create(:user, :complete_company_owner)
    user.confirm
    user.company.accepted!
    product = create(:product, company: user.company)
    product.disabled!

    login_as user, scope: :user
    visit product_path(product)
    click_on 'Habilitar'

    expect(page).to have_content('Habilitado')
    expect(page).not_to have_content('Desabilitado')
    expect(product.reload.status).to eq 'enabled'
  end
end
