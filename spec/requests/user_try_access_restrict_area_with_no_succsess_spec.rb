require 'rails_helper'

describe 'Authenticated User try access restrict adimin area' do
  it 'and cannot open form to create a payment_method' do
    user = create(:user)
    user.confirm

    login_as user, scope: :user

    get '/admin/payment_methods/new'

    expect(response).not_to redirect_to(admin_payment_methods_path)
  end
  it 'and cannot create a payment_method' do
    user = create(:user)
    user.confirm

    login_as user, scope: :user

    post '/admin/payment_methods'

    expect(response).not_to redirect_to(admin_payment_methods_path)
  end
end
