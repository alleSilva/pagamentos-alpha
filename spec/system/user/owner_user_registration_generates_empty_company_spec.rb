require 'rails_helper'

describe '(owner)User registration generates empty company' do
  it 'successfully' do
    user = create(:user, owner: true)
    user.confirm

    login_as user, scope: :user
    visit root_path

    expect(user.company.incomplete?).to be(true)
    expect(page).to have_content('Você já se cadastrou no nosso sistema, mas '\
                                 'agora precisa registrar a sua empresa! Preencha os dados abaixo para '\
                                 'podermos conhecer sua empresa:')
    expect(page).to have_css('#company_cnpj')
    expect(page).to have_css('#company_legal_name')
    expect(page).to have_css('#company_billing_address')
    expect(page).to have_css('#company_billing_email')
  end

  it 'and cannot see navbar with options' do
    user = create(:user, owner: true)
    user.confirm

    login_as user, scope: :user
    visit root_path

    expect(user.company.incomplete?).to be(true)
    expect(page).to have_content('Você já se cadastrou no nosso sistema, mas '\
                                 'agora precisa registrar a sua empresa! Preencha os dados abaixo para '\
                                 'podermos conhecer sua empresa:')
    expect(page).not_to have_content('Criar produto')
  end
end
