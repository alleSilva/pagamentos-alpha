owner = FactoryBot.create(
    :user, :complete_company_owner, 
    email: 'owner@gamestream.com'
)
owner.confirm
gamestream = owner.company
gamestream.accepted!
gamestream.token = 'rVAfNGdvfh6va61nDv11'

user = FactoryBot.create(
    :user, 
    email: 'staff@gamestream.com',
    company: gamestream
)
user.confirm
admin = FactoryBot.create(:admin, email:'admin@pagapaga.com.br')
admin.confirm

FactoryBot.create(
    :product,
    company: gamestream,
    type_of: 'single',
    name: 'Vídeo de Minecraft'
)

FactoryBot.create(
    :product,
    company: gamestream,
    type_of: 'single',
    name: 'Vídeo de Valorant'
)

FactoryBot.create(
    :product,
    company: gamestream,
    type_of: 'subscription',
    name: 'Assinatura de treinamento de Valorant'
)

other_owner = FactoryBot.create(:user, :complete_company_owner)
company = owner.company
company.accepted!

product = FactoryBot.create(
    :product,
    company: company,
    type_of: 'single',
    name: 'Vídeo de Tetris'
)

FactoryBot.create(
    :pix_setting,
    company: company,
    pix_key: '2134641242',
    bank_code: "001"
)

FactoryBot.create(
    :pix_setting,
    company: company,
    pix_key: '6757658346',
    bank_code: "001"
)

pix_setting = FactoryBot.create(
    :pix_setting,
    company: company,
    pix_key: '90803452a',
    bank_code: "001"
)

boleto_setting = FactoryBot.create(
    :boleto_setting,
    company: company,
    agency_number: '42424',
    account_number: '3434',
    bank_code: "001"
)

FactoryBot.create(
    :boleto_setting,
    company: company,
    agency_number: '42',
    account_number: '342324',
    bank_code: "001"
)

FactoryBot.create(
    :boleto_setting,
    company: company,
    agency_number: '21231',
    account_number: '90803452a',
    bank_code: "001"
)

FactoryBot.create(
    :credit_card_setting,
    company: company,
    company_code: '767676'
)

FactoryBot.create(
    :credit_card_setting,
    company: company,
    company_code: '342432'
)

FactoryBot.create(
    :credit_card_setting,
    company: company,
    company_code: '4243243'
)

customer = FactoryBot.create(
    :customer,
    company: company,
    name: 'John Smith',
    cpf: '12345678910'
)

FactoryBot.create(
    :customer,
    company: company,
    name: 'Joana da Silva',
    cpf: '12345678910'
)

customer_payment_method2 = FactoryBot.create(
    :customer_payment_method,
    customer: customer,
    company: company,
    type_of: 'pix',
    pix_setting: pix_setting
)

customer_payment_method = FactoryBot.create(
    :customer_payment_method,
    customer: customer,
    company: company,
    type_of: 'boleto',
    boleto_setting: boleto_setting
)


FactoryBot.create(
    :purchase,
    customer_payment_method: customer_payment_method,
    product: product,
    company: company
  )

  FactoryBot.create(
    :purchase,
    customer_payment_method: customer_payment_method2,
    product: product,
    company: company
  )
