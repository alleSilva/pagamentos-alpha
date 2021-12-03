require 'rails_helper'

describe 'Product can have status changed' do
  it 'unless user is from another company' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!
    product = FactoryBot.create(:product, company: owner.company)

    owner2 = create(:user, :complete_company_owner)
    owner2.confirm
    owner2.company.accepted!

    login_as owner2, scope: :user
    post disable_product_path product

    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq('Produto não pertence a esta empresa')
  end
end
