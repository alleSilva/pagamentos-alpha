require 'rails_helper'

describe 'Owner cancel registration' do
  it 'successfully' do
    owner = create(:user, owner: true, company: create(:company))
    owner.confirm

    login_as owner, scope: :user
    visit company_path owner.company
    click_on 'Cancelar pedido de registro'

    expect(current_path).to eq(edit_company_path(owner.company))
    expect(page).to have_content('Você já se cadastrou no nosso sistema, mas '\
                                 'agora precisa registrar a sua empresa! Preencha os dados abaixo para '\
                                 'podermos conhecer sua empresa:')
    expect(owner.company.reload.status).to eq('incomplete')
  end
end
