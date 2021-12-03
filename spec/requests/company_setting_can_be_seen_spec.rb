require 'rails_helper'

describe 'company setting can be seen' do
  it 'unless company is not approved' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    login_as owner, scope: :user
    get company_payment_settings_path owner.company

    expect(response).to redirect_to(company_path(owner.company))
    expect(flash[:alert]).to eq('Esta empresa ainda não foi aprovada')
  end

  it 'unless visitor is not logged in' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    get company_payment_settings_path owner.company

    expect(response).to redirect_to(new_user_session_path)
    expect(flash[:alert]).to eq('Para continuar, efetue login ou registre-se.')
  end
end
