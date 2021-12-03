require 'rails_helper'

describe 'Owner sees payment settings' do
  # TODO: testar com setting que não seja de owner.company
  it 'successfully' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    company = owner.company
    company.accepted!

    credit_card_method = create(:payment_method, :credit_card)
    pix_method = create(:payment_method, :pix)
    boleto_method = create(:payment_method, :boleto)

    credit_card_setting = create(
      :credit_card_setting, company: company, payment_method: credit_card_method
    )
    pix_setting = create(
      :pix_setting, company: company, payment_method: pix_method
    )
    boleto_setting = create(
      :boleto_setting, company: company, payment_method: boleto_method
    )

    create(
      :boleto_setting, company: company, payment_method: boleto_method
    )

    login_as owner, scope: :user
    visit company_path company
    click_on 'Meios de pagamento configurados'

    expect(page).to have_content('Configurar novo pix')
    expect(page).to have_content('Configurar novo boleto')
    expect(page).to have_content('Configurar novo cartão de crédito')

    expect(page).to have_content("Chave PIX: #{pix_setting.pix_key}")
    expect(page).to have_content("Código do banco: #{pix_setting.bank_code}")
    expect(page).to have_content("Código do cartão: #{credit_card_setting.company_code}")
    expect(page).to have_content("Código do banco: #{boleto_setting.bank_code}")
    expect(page).to have_content("Número da agência: #{boleto_setting.agency_number}")
    expect(page).to have_content("Número da conta: #{boleto_setting.account_number}")
  end

  it 'unless company is not accepted' do
    owner = create(:user, :complete_company_owner)
    owner.confirm
    company = owner.company

    login_as owner, scope: :user
    visit company_path company

    expect(page).to_not have_content('Meios de pagamento configurados')
  end

  it 'pix creation form successfully' do
    pix_method, pix_method2, pix_method3 = create_list(:payment_method, 3, :pix)
    pix_method3.disabled!

    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    login_as owner, scope: :user
    visit company_path owner.company
    click_on 'Meios de pagamento configurados'
    click_on 'Configurar novo pix'

    expect(current_path).to eq(new_pix_setting_path)
    expect(page).to have_content('Digite as informações abaixo para registrar um novo pagamento PIX:')
    expect(page).to have_content('Chave PIX')
    expect(page).to have_content('Código do banco')
    expect(page).to have_content('Meio de pagamento')
    expect(page).to_not have_content(pix_method3.name)
    expect(page).to have_content(pix_method.name)
    expect(page).to have_content(pix_method2.name)
  end

  it 'credit card creation form successfully' do
    credit_card_method, credit_card_method2, credit_card_method3 = create_list(:payment_method, 3, :credit_card)
    credit_card_method3.disabled!

    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    login_as owner, scope: :user
    visit company_path owner.company
    click_on 'Meios de pagamento configurados'
    click_on 'Configurar novo cartão de crédito'

    expect(current_path).to eq(new_credit_card_setting_path)
    expect(page).to have_content('Digite as informações abaixo para registrar um novo cartão de crédito:')
    expect(page).to have_content('Código do cartão')
    expect(page).to have_content('Meio de pagamento')
    expect(page).to_not have_content(credit_card_method3.name)
    expect(page).to have_content(credit_card_method.name)
    expect(page).to have_content(credit_card_method2.name)
  end

  it 'boleto creation form successfully' do
    boleto_method, boleto_method2, boleto_method3 = create_list(:payment_method, 3, :boleto)
    boleto_method3.disabled!

    owner = create(:user, :complete_company_owner)
    owner.confirm
    owner.company.accepted!

    login_as owner, scope: :user
    visit company_path owner.company
    click_on 'Meios de pagamento configurados'
    click_on 'Configurar novo boleto'

    expect(current_path).to eq(new_boleto_setting_path)
    expect(page).to have_content('Digite as informações abaixo para registrar um novo pagamento por boleto:')
    expect(page).to have_content('Número da agência')
    expect(page).to have_content('Número da conta')
    expect(page).to have_content('Código do banco')
    expect(page).to_not have_content(boleto_method3.name)
    expect(page).to have_content(boleto_method.name)
    expect(page).to have_content(boleto_method2.name)
  end
end
