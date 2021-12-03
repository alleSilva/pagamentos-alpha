require 'rails_helper'

describe 'admin judge purcheses' do
  it 'and see all purchases' do
    admin = create(:admin)
    admin.confirm
    purchase1 = create(:purchase)
    purchase2 = create(:purchase)

    login_as admin, scope: :admin
    visit root_path
    click_on 'Avaliar Fraudes'

    expect(page).to have_content(purchase1.company.legal_name)
    expect(page).to have_content(purchase2.company.legal_name)
    expect(page).to have_content(purchase1.customer_payment_method.customer.name)
    expect(page).to have_content(purchase2.customer_payment_method.customer.name)
    expect(page).to have_content('R$ 9,99')
    expect(page).to have_content('R$ 9,99')
  end

  it 'and aproves a purchase' do
    admin = create(:admin)
    admin.confirm
    purchase1 = create(:purchase)

    login_as admin, scope: :admin
    visit root_path
    click_on 'Avaliar Fraudes'
    click_on 'Aprovar'

    expect(page).to_not have_content(purchase1.company.legal_name)
    expect(page).to_not have_content(purchase1.customer_payment_method.customer.name)
    expect(page).to_not have_content('R$ 9,99')
    expect(purchase1.reload.status).to eq('pending')
  end

  it 'and see reject page' do
    admin = create(:admin)
    admin.confirm
    _purchase1 = create(:purchase)

    login_as admin, scope: :admin
    visit root_path
    click_on 'Avaliar Fraudes'
    click_on 'Rejeitar'

    expect(page).to have_content('título')
    expect(page).to have_content('descrição')
    expect(page).to have_content('arquivo')
  end

  it 'and reject purchase' do
    admin = create(:admin)
    admin.confirm
    purchase1 = create(:purchase)

    login_as admin, scope: :admin
    visit root_path
    click_on 'Avaliar Fraudes'
    click_on 'Rejeitar'
    fill_in 'título', with: 'Fraude constatada'
    fill_in 'descrição', with: 'Fraude constatada através do nome do cartão diferente'
    click_on 'Enviar constatação de fraude'

    expect(page).to_not have_content(purchase1.company.legal_name)
    expect(page).to_not have_content(purchase1.customer_payment_method.customer.name)
    expect(page).to_not have_content('R$ 9,99')
    expect(purchase1.reload.status).to eq('rejected')
  end

  it 'and doesnt have do judge, purchase automatic goes to rejected' do
    travel_to 3.days.ago do
      admin = create(:admin)
      admin.confirm
      user = create(:user, :complete_company_owner)
      user.confirm
      company = user.company
      company.accepted!
      customer_payment_method = create(:customer_payment_method, :pix, company: company)
      purchase1 = create(:purchase, customer_payment_method: customer_payment_method)
      purchase1.rejected!
      purchase2 = create(:purchase, customer_payment_method: customer_payment_method)
      purchase2.rejected!
    end

    purchase3 = create(:purchase, customer_payment_method: CustomerPaymentMethod.find(1))
    expect(purchase3.reload.status).to eq('rejected')
  end
end
