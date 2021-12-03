require 'rails_helper'

describe 'Visitor registers as (owner)user' do
  it 'successfully' do
    visit root_path
    click_on 'Cadastre-se'

    fill_in 'user_email', with: 'test@company.com'
    fill_in 'user_password', with: '123456789'
    fill_in 'user_password_confirmation', with: '123456789'
    click_on 'commit'

    expect(page).to have_content('Uma mensagem com um link de confirmação foi enviada para o seu endereço de e-mail.'\
                                 ' Por favor, abra o link para confirmar a sua conta.')
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

  it 'and recives a confirmation email' do
    visit new_user_registration_path

    fill_in 'Email', with: 'test@company.com'
    fill_in 'Senha', with: '123456789'
    fill_in 'Confirmação da Senha', with: '123456789'
    click_on 'Cadastrar'

    mail = Devise.mailer.deliveries.first

    expect(Devise.mailer.deliveries.count).to eq 1
    expect(mail.from.first).to eq 'confirmacao@pagapaga.com.br'
    expect(mail.to.first).to eq 'test@company.com'
    expect(mail.subject).to eq 'Instruções de confirmação'
  end
end
