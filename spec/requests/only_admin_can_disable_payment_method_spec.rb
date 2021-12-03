require 'rails_helper'

describe 'Authenticated User try change status of a payment method' do
  it 'and cannot disable' do
    user = create(:user)
    user.confirm
    payment_method = create(:payment_method)

    login_as user, scope: :user

    post "/admin/payment_methods/#{payment_method.id}/disable"

    expect(response).to redirect_to(edit_company_path(user.company))
  end
  it 'and cannot enable' do
    user = create(:user)
    user.confirm
    payment_method = create(:payment_method)

    login_as user, scope: :user

    post "/admin/payment_methods/#{payment_method.id}/enable"

    expect(response).to redirect_to(edit_company_path(user.company))
  end
end
