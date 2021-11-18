require 'rails_helper'

describe 'adminstrator try to create a account' do
  it 'and do it successfuly' do
    visit new_admin_registration_path

    fill_in 'Email', with: 'admin@pagapaga.com.br'
    fill_in 'Senha', with: '123456'
    fill_in 'Confirmação da Senha', with: '123456'

    click_on 'Cadastrar'
  end

  it 'and try to register with a personal e-mail' do
    visit new_admin_registration_path

    fill_in 'Email', with: 'admin@hotmail.com'
    fill_in 'Senha', with: '123456'
    fill_in 'Confirmação da Senha', with: '123456'
    click_on 'Cadastrar'

    expect(page).to have_content('Este e-mail não é válido')
  end

  it 'and leave the email empty' do
    visit new_admin_registration_path

    fill_in 'Email', with: ''
    fill_in 'Senha', with: '123456'
    fill_in 'Confirmação da Senha', with: '123456'
    click_on 'Cadastrar'

    expect(page).to have_content('Email não pode ficar em branco')
  end

  it 'and the password is shorter' do
    visit new_admin_registration_path

    fill_in 'Email', with: 'admin@pagapaga.com.br'
    fill_in 'Senha', with: '123'
    fill_in 'Confirmação da Senha', with: '123'
    click_on 'Cadastrar'

    expect(page).to have_content('Senha é muito curto (mínimo: 6 caracteres)')
  end

  it 'and try to use a already registred email' do
    admin = create(:admin)

    visit new_admin_registration_path

    fill_in 'Email', with: admin.email
    fill_in 'Senha', with: '123456'
    fill_in 'Confirmação da Senha', with: '123456'
    click_on 'Cadastrar'

    expect(page).to have_content("Email #{admin.email} já está em uso")
  end
end
