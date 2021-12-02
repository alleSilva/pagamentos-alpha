require 'rails_helper'

describe 'Product can be created' do
  context 'new path' do
    it 'unless company is not accepted' do
      owner = create(:user, :complete_company_owner)

      login_as owner, scope: :user

      get '/products/new'

      expect(response).to redirect_to(company_path(owner.company))
      expect(flash[:alert]).to eq('Esta empresa ainda não foi aprovada')
    end

    it 'unless user not logged in' do
      get '/products/new'
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'create path' do
    it 'unless company is not accepted' do
      owner = create(:user, :complete_company_owner)

      login_as owner, scope: :user

      post '/products'

      expect(response).to redirect_to(company_path(owner.company))
      expect(flash[:alert]).to eq('Esta empresa ainda não foi aprovada')
    end

    it 'unless user not logged in' do
      post '/products'
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
