require 'rails_helper'

describe 'Visitor registers as (staff)user' do
  it 'successfully' do
    owner = create(:user, :complete_company_owner, email: 'owner@company.com')
    owner.confirm
    owner.company.accepted!

    visit root_path
    click_on 'Cadastre-se'

    fill_in 'user_email', with: 'staff@company.com'
    fill_in 'user_password', with: '123456789'
    fill_in 'user_password_confirmation', with: '123456789'
    click_on 'commit'

    expect(page).to have_content('Uma mensagem com um link de confirmação foi enviada para o seu endereço de e-mail.'\
                                 ' Por favor, abra o link para confirmar a sua conta.')
    current_user = User.last
    expect(current_user.owner).to eq(false)
    expect(current_user.company).to eq(owner.company)
  end

  it 'unless users company is pending' do
    create(:user, :complete_company_owner, email: 'owner@company.com')

    visit root_path
    click_on 'Cadastre-se'

    fill_in 'user_email', with: 'staff@company.com'
    fill_in 'user_password', with: '123456789'
    fill_in 'user_password_confirmation', with: '123456789'
    click_on 'commit'

    expect(page).to have_content('Não foi possível salvar usuário')
    expect(page).to have_content('Sua empresa ainda não foi aceita no nosso sistema')
  end

  it 'unless users company is rejected' do
    owner = create(:user, :complete_company_owner, email: 'owner@company.com')
    owner.company.rejected!

    visit root_path
    click_on 'Cadastre-se'

    fill_in 'user_email', with: 'staff@company.com'
    fill_in 'user_password', with: '123456789'
    fill_in 'user_password_confirmation', with: '123456789'
    click_on 'commit'

    expect(page).to have_content('Não foi possível salvar usuário')
    expect(page).to have_content('Sua empresa ainda não foi aceita no nosso sistema')
  end

  it 'unless users company is incomplete' do
    create(:user, email: 'owner@company.com')

    visit root_path
    click_on 'Cadastre-se'

    fill_in 'user_email', with: 'staff@company.com'
    fill_in 'user_password', with: '123456789'
    fill_in 'user_password_confirmation', with: '123456789'
    click_on 'commit'

    expect(page).to have_content('Não foi possível salvar usuário')
    expect(page).to have_content('Sua empresa ainda não foi aceita no nosso sistema')
  end
end
