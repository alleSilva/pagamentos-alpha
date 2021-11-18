require 'rails_helper'

describe 'Visitor registers as user' do
  it 'successfully' do
    visit root_path
    click_on 'Cadastre-se'

    fill_in 'user_email', with: 'test@company.com'
    fill_in 'user_password', with: '123456789'
    fill_in 'user_password_confirmation', with: '123456789'
    click_on 'commit'

    expect(page).to have_content('Login efetuado com sucesso')
    expect(page).to have_content('Você já se cadastrou no nosso sistema, mas '\
      'agora precisa registrar a sua empresa! Preencha os dados abaixo para '\
      'podermos conhecer sua empresa:')
  end

  it 'and fails when using a public email domain' do
    visit root_path
    click_on 'Cadastre-se'

    fill_in 'user_email', with: 'test@gmail.com'
    fill_in 'user_password', with: '123456789'
    fill_in 'user_password_confirmation', with: '123456789'
    click_on 'commit'

    expect(page).to have_content('Email não pode ser um email de domínio público')
  end
end
