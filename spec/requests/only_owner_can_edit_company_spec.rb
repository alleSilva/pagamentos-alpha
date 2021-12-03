require 'rails_helper'

describe 'company can be edited' do
  it 'if user is the company owner and company is not pending' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    login_as owner, scope: :user
    get edit_company_path owner.company

    expect(response.status).to eq(200)
  end

  it 'unless user is the company owner but company is pending' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    login_as owner, scope: :user
    get edit_company_path owner.company

    expect(response).to redirect_to company_path owner.company
  end

  it 'unless user is linked to the company but isnt owner' do
    owner = create(:user, owner: true)
    owner.confirm
    user = create(:user, owner: false, company: owner.company)
    user.confirm

    login_as user, scope: :user
    get edit_company_path owner.company

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq('Você não tem permissão para alterar os dados '\
                                'dessa empresa.')
  end

  it 'unless user is from another company' do
    owner = create(:user, owner: true)
    owner.confirm

    owner2 = create(:user, owner: true)
    owner2.confirm
    user = create(:user, owner: false, company: owner2.company)
    user.confirm

    login_as user, scope: :user
    get edit_company_path owner.company

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq('Você não tem permissão para alterar os dados '\
                                'dessa empresa.')
  end

  it 'unless visitor is not signed in' do
    owner = create(:user, owner: true)

    get edit_company_path owner.company

    expect(response).to redirect_to(new_user_session_path)
  end

  xit 'unless user is an admin' do
    # TODO: Esse fica pra quando tiver o admin pronto
  end
end
