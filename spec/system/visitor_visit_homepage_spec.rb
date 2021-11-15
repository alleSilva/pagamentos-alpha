require 'rails_helper'

describe 'Visitor visit homepage' do
  it 'successfully' do
    visit root_path

    expect(page).to have_link('PagaPaga')
    expect(page).to have_link('Registrar-se')
    expect(page).to have_link('Entrar')
    expect(page).to have_content('Boas vindas ao sistema de pagamentos PagaPaga!')
  end
end
