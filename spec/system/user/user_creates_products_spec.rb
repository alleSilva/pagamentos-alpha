require 'rails_helper'

describe 'authenticated user creates a new product' do
  it 'must be signed in' do
    visit products_path

    expect(page).to have_content('Para continuar, efetue login ou registre-se.')
  end

  it 'successfully as subscription' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    login_as owner, scope: :user
    visit company_path(owner.company)
    click_on 'Criar produto'

    select 'Assinatura', from: 'product_type_of'
    fill_in 'Nome', with: 'Playlist Minecraft'

    within 'form' do
      click_on 'Criar'
    end

    expect(page).to have_content('Produto criado com sucesso')
    expect(page).to have_content('Nome: Playlist Minecraft')
    expect(page).to have_content('Estado: Habilitado')
    expect(page).to have_content("Token de integração: #{Product.last.token}")
  end

  it 'successfully as product' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    login_as owner, scope: :user
    visit company_path(owner.company)
    click_on 'Criar produto'

    fill_in 'Nome', with: 'VIdeo Minecraft'
    select 'Produto avulso', from: 'product_type_of'

    within 'form' do
      click_on 'Criar'
    end

    expect(page).to have_content('Produto criado com sucesso')
    expect(page).to have_content('Nome: VIdeo Minecraft')
    expect(page).to have_content('Estado: Habilitado')
    expect(page).to have_content("Token de integração: #{Product.last.token}")
  end

  it 'fails on empty name' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    login_as owner, scope: :user
    visit company_path(owner.company)
    click_on 'Criar produto'

    within 'form' do
      click_on 'Criar'
    end

    expect(page).to have_content('não pode ficar em branco')
  end
end
