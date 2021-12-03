require 'rails_helper'

describe 'only admin can see companies' do
  it 'so a user with no filed company try to access companies' do
    owner = create(:user, owner: true)
    owner.confirm

    login_as owner, scope: :user
    get companies_path

    expect(response).to redirect_to(edit_company_path(owner.company))
  end

  it 'so a user with filed company try to access companies' do
    owner = create(:user, :complete_company_owner)
    owner.confirm

    login_as owner, scope: :user
    get companies_path

    expect(response).to redirect_to(new_admin_session_path)
  end

  it 'so a visitor try to access companies' do
    get companies_path

    expect(response).to redirect_to(new_admin_session_path)
  end

  context 'and only him can do actions' do
    it 'so a user tries to accept his own company' do
      owner = create(:user, :complete_company_owner)
      owner.confirm

      login_as owner, scope: :user
      post accept_company_path(owner.company)

      expect(response).to redirect_to(new_admin_session_path)
    end

    it 'so a user tries to accept a random company' do
      owner = create(:user, :complete_company_owner)
      owner.confirm

      post accept_company_path(owner.company)

      expect(response).to redirect_to(new_admin_session_path)
    end

    it 'so a user tries to reject his own company' do
      owner = create(:user, :complete_company_owner)
      owner.confirm

      login_as owner, scope: :user
      post company_rejected_companies_path(owner.company)

      expect(response).to redirect_to(new_admin_session_path)
    end

    it 'so a user tries to reject a random company' do
      owner = create(:user, :complete_company_owner)
      owner.confirm

      post company_rejected_companies_path(owner.company)

      expect(response).to redirect_to(new_admin_session_path)
    end
  end
end
