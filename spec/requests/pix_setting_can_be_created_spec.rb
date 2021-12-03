require 'rails_helper'

describe 'pix setting can be created' do
  it 'unless company is not approved(form)' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    login_as owner, scope: :user
    get new_pix_setting_path

    expect(response).to redirect_to(company_path(owner.company))
    expect(flash[:alert]).to eq('Esta empresa ainda não foi aprovada')
  end
  it 'unless company is not approved(post)' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    login_as owner, scope: :user
    post pix_settings_path

    expect(response).to redirect_to(company_path(owner.company))
    expect(flash[:alert]).to eq('Esta empresa ainda não foi aprovada')
  end
end
