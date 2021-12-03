require 'rails_helper'

describe 'Owner sees company token' do
  it 'successfully if approved' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    login_as owner, scope: :user
    visit company_path owner.company

    expect(page).to have_content('Este token representa sua empresa na nossa API:')
    expect(page).to have_content(owner.company.token)
    expect(owner.company.token.size).to eq(20)
  end
end
