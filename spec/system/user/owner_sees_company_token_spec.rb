require 'rails_helper'

describe 'Owner sees company token' do
  it 'successfully if approved' do
    owner = create(:user, :complete_company_owner)
    owner.company.accepted!

    login_as owner, scope: :user
    visit company_path owner.company

    expect(page).to have_content('Use este token para que funcionários da sua '\
                                  'empresa possam ter acesso a ela:')
    expect(page).to have_content(owner.company.token)
    expect(owner.company.token.size).to eq(20)
  end
end
