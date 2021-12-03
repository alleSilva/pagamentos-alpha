require 'rails_helper'

describe 'company page can be seen' do
  it 'by owner' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    login_as owner, scope: :user
    get company_path owner.company

    expect(response.status).to eq(200)
  end

  it 'by normal user linked to the company' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    user = create(:user, owner: false, company: owner.company)
    user.confirm

    login_as user, scope: :user
    get company_path owner.company

    expect(response.status).to eq(200)
  end

  it 'unless user is from another company' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    owner2 = create(:user, :complete_company_owner)
    owner2.confirm
    user = create(:user, owner: false, company: owner2.company)
    user.confirm

    login_as user, scope: :user
    get company_path owner.company

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq('Você não tem permissão para ver os dados '\
                                'dessa empresa.')
  end

  it 'unless visitor is not signed in' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    get company_path owner.company

    expect(response).to redirect_to(new_user_session_path)
  end

  xit 'unless user is an admin' do
    # TODO: Esse fica pra quando tiver o admin pronto
  end
end
