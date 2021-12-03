require 'rails_helper'

describe 'Owner sees company token' do
  it 'successfully if approved' do
    owner = create(:user, owner: true)
    owner.confirm

    login_as owner, scope: :user
    visit root_path
    click_on 'Logout'

    expect(page).to have_content('Saiu com sucesso.')
    expect(current_path).to eq(root_path)
  end
end
